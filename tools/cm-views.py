#!/usr/bin/env python3
"""CursorMemo Views — a tiny, read-only companion for the ai-memory dashboard.

The upstream dashboard (http://127.0.0.1:49374/web) already covers projects,
page browsing, search, health, and a pending-writes queue. What it does not
have: a Task view, a Decision Log, a Timeline, or Myanmar language.

This script reads the engine's Markdown wiki directly (no server needed) and
generates ONE bilingual (Myanmar/English) static HTML file with exactly
those views, built only from recorded data:

  * Tasks     — pages with tier=working or tag=pending
  * Decisions — pages with kind=decision
  * Timeline  — every page, newest first, by its frontmatter timestamp

Usage:
  python3 tools/cm-views.py [--data-dir ~/.local/share/ai-memory] [--out cm-views.html]

Local-first: it reads files under the data dir and writes one HTML file.
Nothing is uploaded anywhere. Facts are shown as recorded; nothing is
inferred or invented.
"""
import argparse, html, os, re, sys
from pathlib import Path

def parse_frontmatter(text):
    fm, body = {}, text
    if text.startswith("---"):
        end = text.find("\n---", 3)
        if end != -1:
            raw, body = text[3:end], text[end + 4:]
            cur = None
            for line in raw.splitlines():
                m = re.match(r"^(\S[^:]*):\s*(.*)$", line)
                if m and not line.startswith((" ", "\t")):
                    cur = m.group(1).strip(); fm[cur] = m.group(2).strip()
                elif cur == "generated" and ":" in line:
                    k, v = line.strip().split(":", 1)
                    fm["generated_" + k.strip()] = v.strip()
                elif cur == "tags":
                    v = line.strip().lstrip("- ").strip()
                    if v: fm.setdefault("tags_list", []).append(v)
            t = fm.get("tags", "")
            if t.startswith("["):
                fm["tags_list"] = [x.strip().strip("'\"") for x in t.strip("[]").split(",") if x.strip()]
    return fm, body.strip()

def first_line(body):
    for line in body.splitlines():
        s = line.strip()
        if not s or s.startswith("#"):
            continue
        return s[:180]
    return ""

def collect(data_dir):
    wiki = Path(data_dir) / "wiki"
    if not wiki.is_dir():
        sys.exit(f"wiki not found under {data_dir} — is ai-memory installed and set up?")
    names = {}
    for meta in wiki.rglob("_meta.md"):
        fm, _ = parse_frontmatter(meta.read_text(encoding="utf-8", errors="replace"))
        rel = meta.parent.relative_to(wiki)
        if "project" in fm: names[str(rel)] = fm["project"]
        elif "workspace" in fm: names[str(rel)] = fm["workspace"]
    pages = []
    for md in sorted(wiki.rglob("*.md")):
        if md.name == "_meta.md":
            continue
        fm, body = parse_frontmatter(md.read_text(encoding="utf-8", errors="replace"))
        rel = md.relative_to(wiki)
        scope = str(rel.parent.parent) if len(rel.parts) > 2 else str(rel.parent)
        pages.append({
            "project": names.get(scope, scope),
            "path": "/".join(rel.parts[2:]) if len(rel.parts) > 2 else rel.name,
            "title": fm.get("title") or md.stem,
            "kind": fm.get("kind", ""), "tier": fm.get("tier", ""),
            "tags": fm.get("tags_list", []),
            "at": fm.get("generated_at", ""),
            "summary": first_line(body),
        })
    pages.sort(key=lambda p: p["at"], reverse=True)
    return pages

CSS = """
body{margin:0;background:#05070f;color:#f4f6ff;font-family:system-ui,'Noto Serif Myanmar',sans-serif;line-height:1.7}
.wrap{max-width:980px;margin:0 auto;padding:24px 18px 60px}
h1{font-size:26px} h2{font-size:20px;margin-top:36px;color:#7dd3fc}
.card{background:rgba(18,24,50,.55);border:1px solid rgba(148,163,255,.16);border-radius:14px;padding:16px 20px;margin:10px 0}
.meta{color:#a9b2d8;font-size:13px}
.tag{display:inline-block;border:1px solid rgba(56,189,248,.5);color:#7dd3fc;border-radius:999px;padding:0 10px;font-size:12px;margin-right:6px}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(140px,1fr));gap:12px}
.stat{background:rgba(18,24,50,.55);border:1px solid rgba(148,163,255,.16);border-radius:14px;padding:14px;text-align:center}
.stat b{display:block;font-size:26px;background:linear-gradient(92deg,#22d3ee,#a855f7);-webkit-background-clip:text;background-clip:text;color:transparent}
button{background:rgba(18,24,50,.6);border:1px solid rgba(148,163,255,.3);color:#f4f6ff;border-radius:999px;padding:6px 16px;cursor:pointer}
html[data-lang=mm] .en{display:none} html[data-lang=en] .mm{display:none}
"""

def page_card(p, extra=""):
    tags = "".join(f'<span class="tag">{html.escape(t)}</span>' for t in p["tags"])
    return (f'<div class="card"><b>{html.escape(p["title"])}</b> {extra}<br>'
            f'<span class="meta">{html.escape(p["project"])} · {html.escape(p["path"])} · '
            f'{html.escape(p["kind"])}/{html.escape(p["tier"])} · {html.escape(p["at"])}</span><br>'
            f'{tags}<div>{html.escape(p["summary"])}</div></div>')

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--data-dir", default=os.path.expanduser("~/.local/share/ai-memory"))
    ap.add_argument("--out", default="cm-views.html")
    a = ap.parse_args()
    pages = collect(a.data_dir)
    tasks = [p for p in pages if p["tier"] == "working" or "pending" in p["tags"]]
    decisions = [p for p in pages if p["kind"] == "decision"]
    projects = sorted({p["project"] for p in pages})

    def bi(mm, en):
        return f'<span class="mm">{mm}</span><span class="en">{en}</span>'

    out = f"""<!DOCTYPE html>
<html lang="my" data-lang="mm"><head><meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CursorMemo Views</title><style>{CSS}</style></head><body><div class="wrap">
<div style="float:right"><button onclick="setLang('mm')">မြန်မာ</button> <button onclick="setLang('en')">EN</button></div>
<h1>🧠 CursorMemo Views</h1>
<p class="meta">{bi('မှတ်စုထဲက မှတ်တမ်းတင်ထားတဲ့ အချက်အလက်တွေကိုပဲ ပြထားတာ — ခန့်မှန်းထားတာ မဟုတ်ဘူး။ Read-only companion: ပြင်ချင်/ဖျက်ချင် ရင် upstream dashboard နဲ့ CLI ကို သုံးပါ။', 'Generated only from recorded memory pages — nothing inferred. Read-only companion: use the upstream dashboard or CLI to edit or delete.')}</p>
<div class="grid">
<div class="stat"><b>{len(projects)}</b>{bi('Project များ', 'Projects')}</div>
<div class="stat"><b>{len(pages)}</b>{bi('မှတ်စု စာမျက်နှာ', 'Memory pages')}</div>
<div class="stat"><b>{len(tasks)}</b>{bi('လုပ်ရန်ကျန်', 'Open tasks')}</div>
<div class="stat"><b>{len(decisions)}</b>{bi('ဆုံးဖြတ်ချက်များ', 'Decisions')}</div>
</div>
<h2>{bi('📌 လုပ်ရန်ကျန်တာတွေ (Tasks)', '📌 Tasks')}</h2>
{''.join(page_card(p) for p in tasks) or '<p class="meta">—</p>'}
<h2>{bi('🧭 ဆုံးဖြတ်ချက် မှတ်တမ်း (Decision Log)', '🧭 Decision Log')}</h2>
{''.join(page_card(p) for p in decisions) or '<p class="meta">—</p>'}
<h2>{bi('🕒 အချိန်မှတ်တမ်း (Timeline)', '🕒 Timeline')}</h2>
{''.join(page_card(p) for p in pages)}
<p class="meta">CursorMemo Views · generated locally from {html.escape(a.data_dir)}/wiki · engine: ai-memory (MIT, akitaonrails)</p>
</div><script>function setLang(l){{document.documentElement.dataset.lang=l;document.documentElement.lang=(l==='en'?'en':'my')}}</script>
</body></html>"""
    Path(a.out).write_text(out, encoding="utf-8")
    print(f"wrote {a.out}: {len(pages)} pages, {len(tasks)} tasks, {len(decisions)} decisions, {len(projects)} projects")

if __name__ == "__main__":
    main()
