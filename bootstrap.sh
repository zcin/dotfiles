#!/usr/bin/env bash

# Bootstrap a fresh Intertubin dev pod. This script may run again whenever the
# pod/container is recreated, so every operation should be safe to repeat.
set -uo pipefail

DOTFILES_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

warn() {
  printf 'bootstrap warning: %s\n' "$*" >&2
}

clone_if_missing() {
  local repository="$1"
  local destination="$2"

  if [[ -d "$destination/.git" ]]; then
    return 0
  fi

  if [[ -e "$destination" ]]; then
    warn "$destination exists but is not a Git checkout; skipping $repository"
    return 0
  fi

  git clone --depth 1 "$repository" "$destination" || \
    warn "could not clone $repository"
}

# Install the minimum system packages needed by this shell configuration.
apt-get update || warn "could not update apt package metadata"
DEBIAN_FRONTEND=noninteractive apt-get install -y zsh || warn "could not install zsh"
DEBIAN_FRONTEND=noninteractive apt-get install -y ncurses-bin || warn "could not install ncurses-bin"
DEBIAN_FRONTEND=noninteractive apt-get install -y stow || warn "could not install stow"

# Make future SSH sessions use zsh. The pod startup process itself remains bash.
if zsh_path="$(command -v zsh 2>/dev/null)"; then
  current_shell="$(getent passwd root | cut -d: -f7)"
  if [[ "$current_shell" != "$zsh_path" ]]; then
    usermod --shell "$zsh_path" root || warn "could not set root's login shell to $zsh_path"
  fi
else
  warn "zsh is unavailable; SSH sessions will keep using the existing login shell"
fi

# Install the repository-backed configuration into root's home. Ignore this
# bootstrap entry point itself; it belongs in the checkout, not at ~/bootstrap.sh.
if command -v stow >/dev/null 2>&1; then
  (
    cd "$DOTFILES_DIR"
    stow --target="$HOME" --restow --ignore='(^|/)bootstrap\.sh$' .
  ) || warn "stow could not install the dotfiles; resolve its reported conflicts and rerun bootstrap.sh"
else
  warn "stow is unavailable; dotfiles were not linked into $HOME"
fi

# Dependencies referenced by .zshrc and .tmux.conf.
mkdir -p "$HOME/.zsh" "$HOME/.tmux/plugins"
clone_if_missing https://github.com/sindresorhus/pure.git "$HOME/.zsh/pure"
clone_if_missing https://github.com/tmux-plugins/tpm.git "$HOME/.tmux/plugins/tpm"

# .zshrc uses `fzf --zsh`, which requires a recent fzf release.
if ! command -v fzf >/dev/null 2>&1 || ! fzf --zsh >/dev/null 2>&1; then
  clone_if_missing https://github.com/junegunn/fzf.git "$HOME/.fzf"
  if [[ -x "$HOME/.fzf/install" ]]; then
    "$HOME/.fzf/install" --bin || warn "could not install fzf"
  fi
fi

# If the Ghostty terminfo source is committed to this repository, compile it
# into the persistent home directory for tmux and other terminal applications.
ghostty_terminfo="$DOTFILES_DIR/terminfo/xterm-ghostty.terminfo"
if [[ -f "$ghostty_terminfo" ]] && command -v tic >/dev/null 2>&1; then
  mkdir -p "$HOME/.terminfo"
  tic -x -o "$HOME/.terminfo" "$ghostty_terminfo" || \
    warn "could not compile Ghostty terminfo"
fi

printf 'Dotfiles bootstrap complete. New SSH sessions will use %s.\n' \
  "$(getent passwd root | cut -d: -f7)"
