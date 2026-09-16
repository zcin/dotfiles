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
