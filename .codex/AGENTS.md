- **Cite code-backed claims** — when explaining code behavior, configuration,
  defaults, or limits, include a file-and-line pointer next to each
  claim. Cite the implementation or configuration that establishes it.
  Distinguish observed behavior from inference.
- **Make runtime claims reproducible** — when reporting observed API responses,
  command output, or runtime behavior, include the exact command used to verify
  the claim. For HTTP requests, provide a copy-pasteable curl command with the
  URL, method, relevant headers, and body. Include the working directory and
  environment variables when needed. Never expose credentials; use clearly
  marked placeholders. Distinguish observed output from expected output, and
  note fields or results that may vary between runs.

## Persistent agent artifacts

Store durable investigation artifacts, reports, captures, and handoff bundles under:

`$HOME/agent-workspaces/<task-name>/`

Use one descriptive lowercase kebab-case subdirectory per task and include a `README.md` with its purpose and entry points. Do not rely on `/tmp` for artifacts that must survive pod restarts. Keep live service runtime files in their service-required locations.
