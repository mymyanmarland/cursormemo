<div align="center">

<img src="assets/banner.svg" alt="CursorMemo — long-term memory for AI coding agents" width="100%"/>

<img src="assets/typing.svg" alt="Your AI never forgets" width="640"/>

<br/>

[![License: MIT](https://img.shields.io/badge/License-MIT-38bdf8?style=for-the-badge)](LICENSE)
[![Engine](https://img.shields.io/badge/Engine-ai--memory%203.1.1%20·%20pinned-a855f7?style=for-the-badge)](docs/ARCHITECTURE.md)
[![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20Linux%20%7C%20macOS-22d3ee?style=for-the-badge)](#-တင်နည်း-install)
[![Website](https://img.shields.io/badge/Website-cursormemo.funapp.live-0ea5e9?style=for-the-badge)](https://cursormemo.funapp.live)

**Website:** https://cursormemo.funapp.live — မြန်မာလို လမ်းညွှန် အပြည့်အစုံ (ဘာလဲ / တင်နည်း / သုံးနည်း / FAQ)

</div>

<img src="assets/divider.svg" width="100%"/>

## 🧠 ဒါ ဘာလဲ

Cursor ရဲ့ AI က စကားပြောခန်း တစ်ခု ပြီးတိုင်း မေ့သွားတတ်တယ်။ မနေ့က ဘာလုပ်ခဲ့လဲ ဒီနေ့ ပြန်မေးရင် မမှတ်မိတော့ဘူး။

ဒီ tool က **မှတ်စုစာအုပ်တစ်အုပ်** နဲ့ တူတယ်။ မင်း အလုပ်လုပ်နေတိုင်း ဘာလုပ်ခဲ့လဲ၊ ဘာအဆင်ပြေလဲ၊ ဘာကျန်နေသေးလဲ ဆိုတာ တိတ်တိတ်လေး မှတ်ထားပေးတယ်။ နောက်တစ်ခါ project ဖွင့်တာနဲ့ AI က အဲ့ဒီမှတ်စုကို ကြိုဖတ်ထားပြီးသား ဖြစ်နေတယ်။ မင်း အစကနေ ပြန်ရှင်းပြစရာ မလိုတော့ဘူး။

နောက်ကွယ်မှာ အလုပ်လုပ်ပေးတာက `ai-memory` ဆိုတဲ့ open source program (MIT license, GitHub star တစ်သောင်းကျော်)။ ဒီ repo ကတော့ မြန်မာအသုံးပြုသူတွေ အလွယ်တကူ တင်သုံးနိုင်အောင် ပြင်ဆင်ထားတဲ့ ထုပ်ပိုးမှုပဲ။ Code ကို ပြန်ရေးထားတာ မဟုတ်ဘူး။

## ⚙️ ဘယ်လို အလုပ်လုပ်လဲ

<div align="center">
<img src="assets/flow.svg" alt="Capture, sanitize, consolidate, recall" width="100%"/>
</div>

Session တစ်ခု ပြီးတိုင်း မှတ်စုတွေကို markdown wiki page တွေ အဖြစ် စုစည်းပြီး git နဲ့ version မှတ်ထားတယ်။ Data အကုန် ကိုယ့်စက်ထဲမှာပဲ — cloud မပို့ဘူး၊ API key မလိုဘူး၊ LLM ခေါ်ခ မကုန်ဘူး။

## 🗂️ ဘာတွေ မှတ်ထားပေးလဲ

<div align="center">
<img src="assets/nodes.svg" alt="What CursorMemo remembers" width="100%"/>
</div>

- **Decisions** — ဘာကြောင့် ဒီနည်းကို ရွေးခဲ့တာလဲ
- **Bugs & fixes** — ကြုံဖူးတဲ့ bug နဲ့ ပြင်ခဲ့တဲ့နည်း (နောက်တစ်ခါ ထပ်မရှာရအောင်)
- **Open tasks** — လုပ်ရန်ကျန်နေတာတွေ
- **Failed approaches** — စမ်းပြီး မအောင်မြင်ခဲ့တဲ့နည်းတွေ (AI က ထပ်မစမ်းမိအောင်)
- **Rules & preferences** — မင်းရဲ့ လုပ်ပုံလုပ်နည်းတွေ
- **Session summaries** — session တစ်ခုချင်းစီရဲ့ အကျဉ်းချုပ်

<img src="assets/divider.svg" width="100%"/>

## 💻 တင်နည်း (Install)

<div align="center">
<img src="assets/terminal.svg" alt="Installer demo" width="720"/>
</div>

**Windows** — PowerShell ဖွင့်ပြီး ဒါကို ကူးထည့်ပြီး Enter နှိပ်:

```powershell
irm https://cursormemo.funapp.live/install.ps1 | iex
```

**Linux / macOS / WSL2:**

```bash
curl -fsSL https://cursormemo.funapp.live/install.sh | sh
```

ဒါဆိုရင် ဒါတွေ အလိုအလျောက် ဖြစ်သွားမယ်:

1. ai-memory ကို download လုပ်ပြီး တင်ပေးမယ် (version အတိအကျ + checksum စစ်ပြီး)
2. Cursor နဲ့ ချိတ်ပေးမယ် (MCP + hooks + skills) — ရှိပြီးသား settings တွေကို အရင် backup လုပ်ပြီးမှ

## 🚀 တင်ပြီးရင် လုပ်ရန်

1. Cursor ကို ပိတ်ပြီး ပြန်ဖွင့် (သို့မဟုတ် Settings → MCP မှာ ai-memory server ကို ပိတ်/ဖွင့် လုပ်)
2. Project တစ်ခုဖွင့်ပြီး AI ကို မေး: *"What do you remember about this project?"*

## 📅 နေ့တိုင်း သုံးနည်း

ဘာမှ အထူးလုပ်စရာ မလိုဘူး။ ပုံမှန်အတိုင်း code ရေးရုံပဲ။ လိုရင် AI ကို ဒီလိုမေးလို့ရတယ်:

- *"Where did we leave off?"* — ဘယ်နေရာမှာ ရပ်ခဲ့လဲ
- *"Have we discussed X?"* — X အကြောင်း ဆွေးနွေးဖူးလား
- *"Catch me up"* — အကျဉ်းချုပ် ပြောပြ

## 🗑️ ဖျက်နည်း

```powershell
ai-memory uninstall --apply
```

Installer နဲ့ ဖျက်ရင်လည်း ရတယ် — မှတ်စုတွေကို မဖျက်ဘူး (`--purge` ထည့်မှသာ အကုန်ဖျက်တယ်၊ အတည်ပြုချက် အရင်တောင်းတယ်):

```bash
bash install.sh --uninstall          # memory ကျန်မယ်
bash install.sh --uninstall --purge  # အကုန်ဖျက်မယ်
```

<img src="assets/divider.svg" width="100%"/>

## 🔐 Version 2.0 — Secure Installer

Installer v2.0 (engine: **ai-memory v3.1.1**, pinned). What's new:

- **Pinned + verified** — the upstream installer script is checked against its published SHA-256 before it runs; the binary archive is verified the same way by the upstream script. No floating "latest", no unverified piping.
- **Config backup first** — existing `~/.cursor/mcp.json` / `hooks.json` are copied to `~/.cursormemo/backups/<timestamp>/` before setup.
- **Modes** (bash): default install · `--update` · `--repair` · `--uninstall` (memory is kept) · `--uninstall --purge` (memory deleted, explicit confirm) · `--dry-run` · `--version`. PowerShell mirrors these as `-Update`, `-Repair`, `-Uninstall`, `-Purge`, `-DryRun`.
- **Download-then-review** — instead of piping: `curl -fsSL https://cursormemo.funapp.live/install.sh -o install.sh`, read it, then `bash install.sh`.
- **Tested** — 16/16 sandbox assertions pass on Linux (fresh install, idempotent re-run, repair, checksum-tamper abort, uninstall preserves memory, purge). Windows `install.ps1` is statically reviewed; a real Windows-machine run is still an open verification item.
- **More agents** — Cursor stays the default, but the engine supports 20+. Verified by CursorMemo in a sandbox: `--agents=cursor,claude-code,codex` (also `gemini-cli`). Other agents work through the same engine setup but are not yet CursorMemo-verified.
- **Companion tools** — `tools/cm-views.py` (bilingual Tasks / Decision Log / Timeline / Project Intelligence page generated from your local wiki) and `tools/cm-backup.sh` (timestamped, checksum-verified backups with preview + restore). See `docs/`.

Docs: [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) · [`docs/FEATURE_GAP_ANALYSIS.md`](docs/FEATURE_GAP_ANALYSIS.md) · [`docs/SECURITY.md`](docs/SECURITY.md) · [`docs/IMPLEMENTATION_PLAN.md`](docs/IMPLEMENTATION_PLAN.md) · [`docs/TEST_PLAN.md`](docs/TEST_PLAN.md) · [`docs/MEMORY_MODEL.md`](docs/MEMORY_MODEL.md) · [`docs/DASHBOARD_MAP.md`](docs/DASHBOARD_MAP.md)

## 🌐 Website preview

<div align="center">
<img src="preview.png" alt="CursorMemo website" width="860"/>
</div>

## 📄 License

- ဒီ ထုပ်ပိုးမှု (installer + လမ်းညွှန်): MIT
- အခြေခံ program `ai-memory`: MIT, © akitaonrails — အသေးစိတ် `NOTICE.md` ကြည့်

<div align="center">
<img src="assets/footer.svg" alt="CursorMemo by Funapp" width="100%"/>
</div>
