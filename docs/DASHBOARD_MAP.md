# Dashboard Map — CursorMemo 2.0 Milestone 3 (groundwork)

**Date:** 2026-10-20 · **Engine:** ai-memory v3.1.1 (pinned) · **Method:** fresh
sandbox install → `serve --transport http --enable-web` on loopback →
page-by-page crawl of `/web` with 3 seeded wiki pages
(`decisions/auth.md`, `bugs/login-500.md`, `tasks/pending.md`) in project
`default/demo-shop`.

## Upstream `/web` dashboard — page inventory

| # | Route | Page | What it shows |
|---|-------|------|---------------|
| 1 | `/web` | Projects index | Workspace/project cards: name, page count, last activity. Top nav: Search pages, Pending, Health, Log out. Banner: *"This browser is for spelunking — auditing what landed… not for serving as project documentation."* Footer: `ai-memory · read-only`. |
| 2 | `/web/search?q=` | Global search | Query + scope filter (All projects / per-project) + kind filter (rule, slot, session, decision, gotcha, concept, procedure, note, preference, fact) + tier filter (working, episodic, semantic, procedural) + "Explain ranking" toggle. Snippet results. **No date filter.** |
| 3 | `/web/health` | Server health | Checks (pass/fail); hooks (accepted, shed 429, outcomes stored/replayed/resumed/ignored-end/failed, dropped by cause); writer/spool/recovery queues; consolidation queue; embedder/models (FTS5 + entity + graph only — embeddings/LLM/reranker disabled in zero-LLM mode); index/storage (fts pages/observations, db bytes, reclaimable). Read-only: *"each fix is a command to run, not a button."* |
| 4 | `/web/pending` | Pending writes | Auto-improvement **proposals** (LLM-suggested wiki edits) awaiting approve/reject, with project filter + sort (project/staged date, confidence, staged newest). Empty state when none. |
| 5 | `/web/w/<ws>/<project>` | Project page | Project-scoped search; Pages tree grouped by namespace (folder cards with counts); **Mailbox** (pending cross-project messages); **Recent Activity** feed (kind badge + page + relative time). |
| 6 | `/web/w/<ws>/<project>/p/<ns>/` | Namespace view | Pages in one namespace; sort: recently updated / title. |
| 7 | `/web/w/<ws>/<project>/p/<path>.md` | Page detail | Title, kind + tier badges, updated/created, rendered markdown, **History** link, **Cited by** backlinks. |
| 8 | `/web/w/<ws>/<project>/h/<path>.md` | History | Version list newest-first; per-version diff; compare-selected; author/size/title metadata. *"Superseded versions stay in the record; nothing here can change them."* |

Auth: bearer token (machine) or web session via `/web/login` (username + token as password). CSRF/X-Frame: `X-Frame-Options: DENY`, `frame-ancestors 'none'`.

## Phase 4 spec mapping

### 4.1 Overview Dashboard — PARTIAL → real gaps
- Covered: project list (name, pages, last activity); engine health counters.
- **Gaps:** no global aggregates (total projects / total memories on one
  screen); no session summaries view; no "last successful capture"; no MCP
  connection status; no per-project hook status (health shows server-wide
  hook accepted/shed counters only); "Pending tasks" is **not** the user's
  tasks — `/web/pending` is LLM auto-improvement proposals.

### 4.2 Project Explorer — MOSTLY COVERED
- Covered: project name, last activity, pages tree (architecture notes /
  decisions / issues are navigable markdown, not structured views).
- **Gaps:** no session history view; no full project path shown; decisions /
  known issues / pending tasks have no dedicated sections (plain wiki pages).

### 4.3 Memory Explorer — MOSTLY COVERED, one hard gap
- Covered: search (global + project-scoped, kind/tier filters, snippets,
  explain-ranking), project filters, detail view, backlinks ("Cited by"),
  version history with diffs.
- **Gaps:** **no date filters** on search; source info shows author "—"
  (no capturing-session link); **edit/delete controls: none — dashboard is
  explicitly read-only** (`ai-memory · read-only`); history has **no
  restore button** (compare only).

### 4.4 Timeline — GAP
- "Recent Activity" is a page-write feed, not a timeline. No sessions view,
  no milestones, no task-completion events, no chronological
  decisions/bug-fixes rollup.

### 4.5 Task & Decision Views — GAP
- No structured task tracker (todo/in-progress/blocked/completed) and no
  decision log (decision/reason/alternatives/date/related files/status).
  Tasks/decisions exist only as markdown the LLM happened to write. Per
  mission rules: build these **only from recorded data**, inferred items
  must be labelled as such.

### 4.6 UI/UX — PARTIAL
- Covered: clean Tailwind UI; `dark:` classes throughout (media-driven,
  **no manual toggle found**); viewport meta (responsive-ish); top nav (no
  sidebar); empty states ("No pending proposals"); real counters, no fake
  stats; accessible skip-link.
- **Gaps:** **English only** (`<html lang="en">`, no i18n toggle —
  mission requires Myanmar + English); top nav not sidebar; no manual
  dark/light toggle.

## Recommendation (for the owner's M3 decision)

Do **not** fork or replace the upstream dashboard. The smallest real-gap
set worth a CursorMemo-side companion (read-only first, reusing
`/api/v1` + wiki files, never a dashboard fork):

1. **Overview+ page** — global aggregates (projects, pages, storage),
   last capture, per-project hook status, MCP status. (Covers 4.1 gaps.)
2. **Timeline view** — sessions + page writes + decisions in one
   chronological feed. (Covers 4.4.)
3. **Task & Decision views** — parsed from recorded pages, inferred items
   labelled. (Covers 4.5; the highest-value, highest-risk item — needs the
   owner's call on parsing rules.)
4. **Burmese localization** for the companion pages. (Covers 4.6 i18n.)

Explicitly **out of scope**: edit/delete/restore in the browser (upstream
chose read-only deliberately — the wiki is git-backed; edits belong in the
agent loop, and the mission's own security posture agrees); date filters
could be a tiny upstream-style query param addition later.

**Estimated shape:** one small static/SSR companion served alongside the
engine on loopback, talking only to read-only `/api/v1` + the wiki tree.
No engine fork, no new storage.

## Milestone 3 outcome (2026-10-20, independently re-verified)

A second live crawl (fresh sandbox, seeded `notes/` pages in `default/projA`)
confirmed this map's inventory: Projects index, project page (Pages /
Mailbox / Recent Activity), page detail routes, `/web/search`, `/web/health`,
`/web/pending`, token/session auth — all as documented above.

**Built: `tools/cm-views.py`** — the read-only companion, smallest form:
reads the wiki tree directly (no server needed) and generates ONE bilingual
(Myanmar/English toggle) static HTML with overview counts plus the three
missing views — **Tasks** (tier=working or tag=pending), **Decision Log**
(kind=decision), **Timeline** (all pages by frontmatter timestamp). Facts
only, recorded pages only, labelled read-only; edit/delete stays with the
agent loop + CLI by design. Verified on sandbox data (3 pages → 1 task,
1 decision extracted correctly). Sample (throwaway data):
https://cursormemo.funapp.live/cm-views-sample.html

**Still open from the recommendation:** an Overview+ with last-capture /
per-project hook status / MCP status needs live server data (`/api/v1` or
CLI `status`/`doctor`) — deferred to a later milestone; the companion's
counts cover the static half. Timeline currently rolls up page writes;
session-level events join it when the session data is mapped the same way.
