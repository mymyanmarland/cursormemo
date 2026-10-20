# Implementation Plan — CursorMemo 2.0

Priorities follow the mission brief: P0 foundation → P1 core product → P2
advanced. Every milestone ends with tests + a report; nothing is claimed
complete without verification.

## Milestone 1 — P0: Audit, plan, secure installer ✅ (2026-10-20)

- [x] Audit current installers; read upstream v3.1.1 installer source; list
      release assets/checksums via GitHub API.
- [x] `docs/ARCHITECTURE.md`, `docs/FEATURE_GAP_ANALYSIS.md`,
      `docs/SECURITY.md`, `docs/IMPLEMENTATION_PLAN.md`, `docs/TEST_PLAN.md`.
- [x] Secure installer v2 (bash): pinned engine v3.1.1, checksum-verified
      bootstrap, OS/arch + dependency preflight, Cursor detection, config
      backup, modes: install / --update / --repair / --uninstall / --purge /
      --dry-run; memory preserved on uninstall by default.
- [x] `install.ps1` v2 mirroring the same flow for Windows.
- [x] Sandbox test matrix (fresh / rerun / repair / dry-run / uninstall /
      purge) — **16/16 assertions PASS**, see TEST_PLAN results.
- [x] Website: version + pinning info; README: installer modes + security.

Exit criteria: installer tests pass in a clean sandbox HOME; no regression to
the v1 happy path; docs shipped in-repo.

## Milestone 2 — P0/P1: Memory model mapping + continuity verification

- Map the mission's 10 memory categories onto the engine's actual wiki/observation
  schema; document what exists vs what needs a CursorMemo-side convention
  (e.g. heading/tag conventions in notes) — no engine patching.
- Scripted continuity test: two scripted sessions (capture → new session →
  recall assertions) against the real binary in a sandbox; crash-interruption
  case (kill mid-session) included.
- Retrieval quality mini-benchmark on a seeded corpus (precision of FTS5
  recall for decision/bug/task queries). Decide on semantic search **only**
  from these numbers.

## Milestone 3 — P1: Dashboard mapping, then (only if gaps are real) extension

- Page-by-page map of the upstream `/web` dashboard against the Phase 4 spec.
- If gaps are real: smallest possible CursorMemo-side companion (read-only
  first), reusing engine data/APIs — never a fork of the dashboard.
- Task & Decision views only from recorded data; inferred items labelled.

## Milestone 4 — P1/P2: Backup & portability wrapper

- `cursormemo backup` / `restore` wrapper around the plain-file store:
  timestamped archives, integrity manifest (sha256), restore preview,
  selective restore, index rebuild via engine.
- Optional scheduled local backups (cron/Task Scheduler templates).

## Milestone 5 — P2: Project intelligence + more agents

- Project status / bug-KB / health views from recorded memories (facts vs
  suggestions labelled).
- Additional MCP-agent presets (Claude Code, Codex…) shipped only after the
  same sandbox + real-machine verification Cursor received.

## Standing rules

- Engine stays pinned; a pin bump is its own tested milestone.
- No paid APIs or cloud dependencies in the default install. Ever.
- Burmese-first docs/site; English always available.
- Windows real-machine e2e remains an explicit open item until the owner runs
  it — CI does not substitute for it.
