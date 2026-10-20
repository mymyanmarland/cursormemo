# Security & Privacy — CursorMemo

## What CursorMemo does to protect you

1. **Pinned engine version.** The installer installs ai-memory **v3.1.1** — a
   specific, tested release — never a floating "latest".
2. **Checksums before execution.** The upstream installer script is downloaded
   together with its published `.sha256` file and verified before it runs. The
   upstream script then verifies the binary archive the same way. A mismatch
   aborts the install; nothing is executed or unpacked.
3. **Config backups before mutation.** Before wiring Cursor, existing
   `~/.cursor/mcp.json` and `~/.cursor/hooks.json` are copied to
   `~/.cursormemo/backups/<timestamp>/`. On failure the installer offers the
   backup path; nothing else in your Cursor config is touched by CursorMemo —
   the merge itself is performed by the upstream `setup` command.
4. **Localhost only.** The engine's server binds to `127.0.0.1` and requires a
   bearer token. It is not reachable from the network by default.
5. **No telemetry, no cloud.** The default installation makes no outbound
   calls except the one-time GitHub release download. Memory data never
   leaves the machine.
6. **Memory is never deleted silently.** Uninstall removes wiring only. The
   engine data directory is deleted solely when the user explicitly passes
   `--purge` (and confirms interactively when a terminal is present).
7. **Inspectable scripts.** Both installers are plain, readable scripts. A
   download-then-review flow is documented in the README for anyone who does
   not want to pipe a script into a shell.

## Secret redaction — honest limitations

The engine redacts recognisable secrets (API keys, tokens, passwords) before
persisting session data. **This is a safety net, not a guarantee:**

- Redaction is pattern-based. Unusual formats, split secrets, secrets inside
  images, or novel token shapes can slip through.
- Anything you paste into a coding session may be captured in some form.
  Treat the memory store as **sensitive data**: it can contain code, file
  paths, error messages, and discussion context.
- Review stored notes any time in the local dashboard
  (`http://127.0.0.1:49374/web`) or as plain Markdown files, and delete
  anything that should not be kept.
- Never commit a memory store to a public repository without reviewing it.

## Data handling facts

- Canonical store: Markdown files on your disk (git-versioned by the engine).
- Index: SQLite FTS5 — derived data, rebuildable from the Markdown store.
- Memory content is **untrusted data**. CursorMemo and the engine treat stored
  notes as reference material for the agent, never as privileged instructions
  that override the user's current request.

## Known residual risks

- A local process running as your user can read the memory store — same trust
  boundary as your source code. OS-level disk encryption is the mitigation.
- Installer supply chain: trust anchors are the GitHub release + its published
  checksums (same origin). This detects corruption/tampering in transit and
  on mirrors; it is not a code-signing PKI.
- Windows installer parity: `install.ps1` v2 implements the same flow but has
  not yet been executed end-to-end on a real Windows machine (tracked openly
  in the README and release notes).
