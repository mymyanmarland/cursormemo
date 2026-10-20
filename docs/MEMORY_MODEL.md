# Memory Model — how the mission's 10 categories map to the engine

_Milestone 2, verified 2026-10-20 against ai-memory v3.1.1 in a live sandbox._

## The engine's native model (verified, not assumed)

Every memory is a Markdown page in a git-versioned wiki, scoped
`workspace → project` (UUID directories + `_meta.md` manifests), indexed in
SQLite (`observations`, `observations_fts`, `page_embeddings`, `entities`,
`handoffs`, `audit_log`, …). Each page carries frontmatter:

- **kind** — `fact | rule | decision | gotcha`
- **tier** — `working | episodic | semantic | procedural`
- **tags** — free-form array
- **provenance** — `generated.by` / `generated.at` (source + timestamp, native)

No CursorMemo-side schema was invented: the kind × tier × tag model covers
the entire mission taxonomy.

## Category mapping

| Mission category | kind | tier | Convention |
|---|---|---|---|
| Project Context | fact | semantic | Also reflected in the project `_meta.md` manifest |
| Architectural Decisions | decision | semantic | Rejected alternatives recorded in the body (verified in benchmark seed) |
| Coding Preferences | rule | procedural | Profile pages may add `applies-to` stack tags + `enforced-by` |
| Bugs and Fixes | gotcha | semantic | Body structure: symptom → root cause → fix → verification |
| Failed Approaches | gotcha | semantic | Plus tag `failed-approach`; never reclassified as success without evidence |
| Completed Work | fact | episodic | Dated entries; engine session pages also land here |
| Pending Tasks | fact | working | Plus tag `pending`; blockers stated in the body |
| Important Discoveries | fact (gotcha when it's a trap) | semantic | — |
| Session Summaries | fact | episodic | Engine-generated at session end via hooks |
| Dependencies & Constraints | fact / rule | semantic | Hard constraints as `rule` |

## Lifecycle features (CLI-verified present in v3.1.1)

- **Version history** — the wiki is a git repo; `checkpoints` lists commits,
  `restore-page` restores a page from a checkpoint and reindexes it.
- **Duplicates / staleness** — `lint` runs the M8 pass (stale + duplicate
  detection, optional LLM contradiction check); `curator` reports rule-based
  findings; `forget-sweep` applies retention decay (pinned pages are exempt).
- **Soft delete + recovery** — `delete-page` removes a page from the index;
  the git checkpoints retain the content for recovery.
- **Provenance & audit** — frontmatter generation stamps + `audit_log` table.
- **Cross-project safety** — `audit-contamination` flags pages whose project
  disagrees with their session.

## Retrieval benchmark (seeded corpus, 2026-10-20)

Corpus: 16 pages across 2 projects (all 10 categories + 2 distractor pages).
9 labelled queries (decision / bug / rule / task / failed-approach /
discovery / constraint / completed-work):

- **Hit@1: 9/9 (100%) · Hit@3: 9/9 (100%)**
- **Latency: median 21 ms, p95 25 ms** per CLI search (FTS5)
- **Isolation:** a project-scoped search returns nothing from other projects;
  `--global` is explicit opt-in and labels every hit with its scope.

**Verdict on semantic search:** NOT justified on this evidence. FTS5 recall
is perfect on the benchmark corpus and embeddings already exist upstream
(`page_embeddings`, `embed` command) if a future, larger and messier corpus
shows real misses. Revisit at 1,000+ pages with adversarial queries — do not
enable by default before then (mission rule).

## Continuity evidence

- Scripted two-process flow: pages written by one process are recalled
  verbatim by a fresh process (the store-level equivalent of session A →
  session B). The generated handoff brief at real session boundaries is
  produced by the engine's Cursor hooks — **live-agent verification still
  requires a real Cursor machine** (open item, owner's Windows PC).
- **Crash test:** server killed with `kill -9`, restarted — every page
  intact and searchable, correct top hit. The Markdown store + WAL-mode
  SQLite survive ungraceful termination.
- Cross-agent handoffs/messages exist upstream (`handoffs` table,
  `message` command) — foundation for later multi-agent presets.
