#!/usr/bin/env python3
"""Per-rank memory calculator for model weights + KV cache.

Currently supports model=kimi. Computes per-rank memory footprint given a
(TP, EP, DP) configuration and per-section parallelism choice.

Sections:
  - attention   : MLA. Parallelism = TP or DP.
  - dense_ffn   : Gated FFN in the first `num_dense_layers`. Always TP.
  - moe         : Routed + shared experts. Parallelism = EP or TP.
  - kv_cache    : MLA compressed KV cache for --num-tokens. Shards by
                  attention parallelism (TP replicates; DP shards seqs).

Weights and KV cache can use different dtypes (--weight-dtype, --kv-dtype).

NOTE: excludes embed_tokens, lm_head, layernorms (small).
"""

import argparse
from dataclasses import dataclass


@dataclass
class KimiConfig:
    hidden_dim: int = 7168
    # MLA
    q_lora_rank: int = 1536
    kv_lora_rank: int = 512
    qk_rope_head_dim: int = 64
    qk_nope_head_dim: int = 128
    v_head_dim: int = 128
    num_heads: int = 64
    # Layers
    num_layers: int = 61
    num_dense_layers: int = 1  # first_k_dense_replace
    # FFN
    dense_intermediate: int = 18432  # TODO: confirm for kimi
    moe_intermediate: int = 2048
    # MoE
    num_routed_experts: int = 384
    num_shared_experts: int = 1
    moe_gated: bool = True  # gated => 3 matmuls per expert (gate, up, down)


MODELS = {
    "kimi": KimiConfig(),
}


def _ffn_matmul_count(gated: bool) -> int:
    return 3 if gated else 2


def attention_params_per_layer(cfg: KimiConfig, tp: int, parallelism: str) -> int:
    """Per-rank params for one MLA layer."""
    q_a = cfg.hidden_dim * cfg.q_lora_rank
    q_b = cfg.q_lora_rank * cfg.num_heads * (cfg.qk_nope_head_dim + cfg.qk_rope_head_dim)
    kv_a = cfg.hidden_dim * (cfg.kv_lora_rank + cfg.qk_rope_head_dim)
    kv_b = cfg.kv_lora_rank * cfg.num_heads * (cfg.qk_nope_head_dim + cfg.v_head_dim)
    o_proj = cfg.num_heads * cfg.v_head_dim * cfg.hidden_dim

    if parallelism == "TP":
        # q_a/kv_a replicated (low-rank, small); q_b/kv_b column-split on heads;
        # o_proj row-split on heads.
        return q_a + kv_a + (q_b + kv_b + o_proj) // tp
    if parallelism == "DP":
        return q_a + q_b + kv_a + kv_b + o_proj
    raise ValueError(f"attention parallelism must be TP or DP, got {parallelism}")


def dense_ffn_params_per_layer(cfg: KimiConfig, tp: int, parallelism: str) -> int:
    if parallelism != "TP":
        raise ValueError(f"dense_ffn parallelism must be TP, got {parallelism}")
    n = _ffn_matmul_count(cfg.moe_gated)  # dense uses same gating convention
    total = n * cfg.hidden_dim * cfg.dense_intermediate
    return total // tp


def moe_params_per_layer(cfg: KimiConfig, tp: int, ep: int, parallelism: str) -> int:
    n = _ffn_matmul_count(cfg.moe_gated)
    expert_params = n * cfg.hidden_dim * cfg.moe_intermediate
    router = cfg.hidden_dim * cfg.num_routed_experts
    shared = cfg.num_shared_experts * expert_params

    if parallelism == "EP":
        if cfg.num_routed_experts % ep != 0:
            raise ValueError(
                f"num_routed_experts {cfg.num_routed_experts} not divisible by EP {ep}"
            )
        routed = (cfg.num_routed_experts // ep) * expert_params
        # shared expert replicated under EP
        return router + routed + shared
    if parallelism == "TP":
        routed = cfg.num_routed_experts * expert_params // tp
        return router + routed + shared // tp
    raise ValueError(f"moe parallelism must be EP or TP, got {parallelism}")


def calculate(
    model: str,
    attention_parallelism: str,
    moe_parallelism: str,
    dense_ffn_parallelism: str,
    tp: int,
    ep: int,
    dp: int,
    sections=("attention", "dense_ffn", "moe"),
    dtype_bytes: int = 2,
) -> dict:
    cfg = MODELS[model]
    moe_layers = cfg.num_layers - cfg.num_dense_layers

    params = {}
    if "attention" in sections:
        params["attention"] = (
            attention_params_per_layer(cfg, tp, attention_parallelism)
            * cfg.num_layers
        )
    if "dense_ffn" in sections:
        params["dense_ffn"] = (
            dense_ffn_params_per_layer(cfg, tp, dense_ffn_parallelism)
            * cfg.num_dense_layers
        )
    if "moe" in sections:
        params["moe"] = (
            moe_params_per_layer(cfg, tp, ep, moe_parallelism) * moe_layers
        )

    bytes_per_section = {k: v * dtype_bytes for k, v in params.items()}
    return {
        "params_per_section": params,
        "bytes_per_section": bytes_per_section,
        "total_params": sum(params.values()),
        "total_bytes": sum(bytes_per_section.values()),
    }


def kv_cache_bytes(
    cfg: KimiConfig, num_tokens: int, bs: int, dtype_bytes: float,
    attention_parallelism: str, dp: int,
) -> tuple[float, float]:
    """Return (all_bytes, per_rank_bytes) for MLA KV cache.

    MLA stores a compressed latent of size (kv_lora_rank + qk_rope_head_dim)
    per token per layer — 576 values for kimi.

    num_tokens is per sequence; bs (batch size) is the number of sequences.
    Under attention=DP, only min(bs, dp) ranks hold sequences, so per-rank
    max = all / min(bs, dp).
    """
    kv_dim = cfg.kv_lora_rank + cfg.qk_rope_head_dim
    all_bytes = cfg.num_layers * kv_dim * num_tokens * dtype_bytes * bs
    if attention_parallelism == "TP":
        per_rank = all_bytes  # compressed cache is replicated across TP ranks
    elif attention_parallelism == "DP":
        effective_dp = min(bs, dp)
        per_rank = all_bytes / effective_dp
    else:
        raise ValueError(f"attention parallelism must be TP or DP, got {attention_parallelism}")
    return all_bytes, per_rank


def fmt_bytes(b: float) -> str:
    for unit in ("B", "KiB", "MiB", "GiB", "TiB"):
        if b < 1024:
            return f"{b:.2f} {unit}"
        b /= 1024
    return f"{b:.2f} PiB"


def fmt_cell(bts, denom):
    pct = (bts / denom * 100) if denom else 0
    return f"{fmt_bytes(bts)} ({pct:.2f}%)"


# nvfp4: 4 bits/param + 8-bit (E4M3) scale per 16-elem block
#        = (16*4 + 8) / 16 bits = 4.5 bits = 0.5625 bytes/param.
DTYPE_TO_BYTES = {
    "fp32": 4, "bf16": 2, "fp16": 2, "fp8": 1, "int8": 1,
    "nvfp4": 0.5625, "int4": 0.5,
}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--model", default="kimi", choices=list(MODELS.keys()))
    p.add_argument("--attention", default="TP", choices=["TP", "DP"])
    p.add_argument("--moe", default="EP", choices=["TP", "EP"])
    # dense_ffn is always TP, sized by --tp (default 8).
    p.add_argument("--tp", type=int, default=8)
    p.add_argument("--ep", type=int, default=None)
    p.add_argument("--dp", type=int, default=None)
    p.add_argument(
        "--sections",
        nargs="+",
        default=["attention", "dense_ffn", "moe", "kv_cache"],
        choices=["attention", "dense_ffn", "moe", "kv_cache"],
        help="Sections to include in the table.",
    )
    p.add_argument(
        "--weight-dtype", default="bf16", choices=list(DTYPE_TO_BYTES.keys()),
        help="Weights dtype. Default bf16.",
    )
    p.add_argument(
        "--kv-dtype", default="fp8", choices=list(DTYPE_TO_BYTES.keys()),
        help="KV cache dtype. Default fp8.",
    )
    p.add_argument(
        "--num-tokens", type=int, default=1,
        help="Tokens per sequence (kv_cache section). Default 1.",
    )
    p.add_argument(
        "--bs", type=int, default=1,
        help="Batch size (concurrent sequences). Caps DP sharding: per-rank "
             "KV cache = all / min(bs, dp). Default 1.",
    )
    args = p.parse_args()

    w_bytes = DTYPE_TO_BYTES[args.weight_dtype]
    kv_bytes = DTYPE_TO_BYTES[args.kv_dtype]

    used = {args.attention, args.moe, "TP"}  # dense_ffn always uses TP
    tp = args.tp
    ep = args.ep if args.ep is not None else (8 if "EP" in used else 1)
    dp = args.dp if args.dp is not None else (8 if "DP" in used else 1)

    weight_secs = [s for s in args.sections if s != "kv_cache"]
    include_kv = "kv_cache" in args.sections

    weight_per_rank = calculate(
        args.model, args.attention, args.moe, "TP",
        tp, ep, dp, tuple(weight_secs), w_bytes,
    )["bytes_per_section"] if weight_secs else {}
    weight_all = calculate(
        args.model, args.attention, args.moe, "TP",
        1, 1, 1, tuple(weight_secs), w_bytes,
    )["bytes_per_section"] if weight_secs else {}

    rows = {}  # section -> (all_bts, per_rank)
    for sec in weight_secs:
        rows[sec] = (weight_all.get(sec, 0), weight_per_rank.get(sec, 0))
    if include_kv:
        cfg = MODELS[args.model]
        kv_all, kv_rank = kv_cache_bytes(
            cfg, args.num_tokens, args.bs, kv_bytes, args.attention, dp,
        )
        rows["kv_cache"] = (kv_all, kv_rank)

    total_all = sum(a for a, _ in rows.values())
    total_per_rank = sum(r for _, r in rows.values())

    print(f"Model: {args.model}")
    print(f"Parallelism: TP={tp} EP={ep} DP={dp}")
    print(f"  attention={args.attention}, moe={args.moe}, dense_ffn=TP")
    print(f"weight_dtype: {args.weight_dtype}, kv_dtype: {args.kv_dtype}")
    if include_kv:
        print(f"num_tokens: {args.num_tokens}, bs: {args.bs}")
    print()

    print(f"{'Section':<12} {'All':>22} {'Per-rank':>22} {'rank/all':>10}")
    print("-" * 70)
    for sec in args.sections:
        if sec not in rows:
            continue
        all_bts, bts = rows[sec]
        ratio = (bts / all_bts) if all_bts else 0
        print(
            f"{sec:<12} {fmt_cell(all_bts, total_all):>22} "
            f"{fmt_cell(bts, total_per_rank):>22} {ratio:>10.4f}"
        )
    print("-" * 70)
    total_ratio = (total_per_rank / total_all) if total_all else 0
    print(
        f"{'TOTAL':<12} {fmt_cell(total_all, total_all):>22} "
        f"{fmt_cell(total_per_rank, total_per_rank):>22} {total_ratio:>10.4f}"
    )


if __name__ == "__main__":
    main()
