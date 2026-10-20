# CursorMemo

Cursor ထဲမှာ code ရေးတိုင်း သုံးတဲ့ AI အတွက် မှတ်ဉာဏ်ကောင်းစေတဲ့ တပ်ဆင်ရေးအထုပ်။

![CursorMemo website](preview.png)

**Website:** https://cursormemo.funapp.live — မြန်မာလို လမ်းညွှန် အပြည့်အစုံ (ဘာလဲ / တင်နည်း / သုံးနည်း / FAQ)

## ဒါ ဘာလဲ

Cursor ရဲ့ AI က စကားပြောခန်း တစ်ခု ပြီးတိုင်း မေ့သွားတတ်တယ်။ မနေ့က ဘာလုပ်ခဲ့လဲ ဒီနေ့ ပြန်မေးရင် မမှတ်မိတော့ဘူး။

ဒီ tool က **မှတ်စုစာအုပ်တစ်အုပ်** နဲ့ တူတယ်။ မင်း အလုပ်လုပ်နေတိုင်း ဘာလုပ်ခဲ့လဲ၊ ဘာအဆင်ပြေလဲ၊ ဘာကျန်နေသေးလဲ ဆိုတာ တိတ်တိတ်လေး မှတ်ထားပေးတယ်။ နောက်တစ်ခါ project ဖွင့်တာနဲ့ AI က အဲ့ဒီမှတ်စုကို ကြိုဖတ်ထားပြီးသား ဖြစ်နေတယ်။ မင်း အစကနေ ပြန်ရှင်းပြစရာ မလိုတော့ဘူး။

နောက်ကွယ်မှာ အလုပ်လုပ်ပေးတာက `ai-memory` ဆိုတဲ့ open source program (MIT license, GitHub star တစ်သောင်းကျော်)။ ဒီ repo ကတော့ မြန်မာအသုံးပြုသူတွေ အလွယ်တကူ တင်သုံးနိုင်အောင် ပြင်ဆင်ထားတဲ့ ထုပ်ပိုးမှုပဲ။ Code ကို ပြန်ရေးထားတာ မဟုတ်ဘူး။

## တင်နည်း (Windows)

PowerShell ဖွင့်ပြီး ဒါကို ကူးထည့်ပြီး Enter နှိပ်:

```powershell
irm https://cursormemo.funapp.live/install.ps1 | iex
```

ဒါဆိုရင် ဒါတွေ အလိုအလျောက် ဖြစ်သွားမယ်:

1. ai-memory ကို download လုပ်ပြီး တင်ပေးမယ်
2. Cursor နဲ့ ချိတ်ပေးမယ် (MCP + hooks + skills)

Linux / macOS / WSL2 သုံးသူများ:

```bash
curl -fsSL https://cursormemo.funapp.live/install.sh | sh
```

## တင်ပြီးရင် လုပ်ရန်

1. Cursor ကို ပိတ်ပြီး ပြန်ဖွင့် (သို့မဟုတ် Settings → MCP မှာ ai-memory server ကို ပိတ်/ဖွင့် လုပ်)
2. Project တစ်ခုဖွင့်ပြီး AI ကို မေး: "What do you remember about this project?"

## နေ့တိုင်း သုံးနည်း

ဘာမှ အထူးလုပ်စရာ မလိုဘူး။ ပုံမှန်အတိုင်း code ရေးရုံပဲ။ လိုရင် AI ကို ဒီလိုမေးလို့ရတယ်:

- "Where did we leave off?" — ဘယ်နေရာမှာ ရပ်ခဲ့လဲ
- "Have we discussed X?" — X အကြောင်း ဆွေးနွေးဖူးလား
- "Catch me up" — အကျဉ်းချုပ် ပြောပြ

## ဖျက်နည်း

```powershell
ai-memory uninstall --apply
```

## Version 2.0 — Secure Installer

Installer v2.0 (engine: **ai-memory v3.1.1**, pinned). What's new:

- **Pinned + verified** — the upstream installer script is checked against its
  published SHA-256 before it runs; the binary archive is verified the same
  way by the upstream script. No floating "latest", no unverified piping.
- **Config backup first** — existing `~/.cursor/mcp.json` / `hooks.json` are
  copied to `~/.cursormemo/backups/<timestamp>/` before setup.
- **Modes** (bash): default install · `--update` · `--repair` · `--uninstall`
  (memory is kept) · `--uninstall --purge` (memory deleted, explicit confirm)
  · `--dry-run` · `--version`. PowerShell mirrors these as `-Update`,
  `-Repair`, `-Uninstall`, `-Purge`, `-DryRun`.
- **Download-then-review** — instead of piping:
  `curl -fsSL https://cursormemo.funapp.live/install.sh -o install.sh`,
  read it, then `bash install.sh`.
- **Tested** — 16/16 sandbox assertions pass on Linux (fresh install,
  idempotent re-run, repair, checksum-tamper abort, uninstall preserves
  memory, purge). Windows `install.ps1` is statically reviewed; a real
  Windows-machine run is still an open verification item.
- **More agents** — Cursor stays the default, but the engine supports 20+.
  Verified by CursorMemo in a sandbox: `--agents=cursor,claude-code,codex`
  (also `gemini-cli`). Other agents work through the same engine setup but
  are not yet CursorMemo-verified.
- **Companion tools** — `tools/cm-views.py` (bilingual Tasks / Decision Log
  / Timeline / Project Intelligence page generated from your local wiki)
  and `tools/cm-backup.sh` (timestamped, checksum-verified backups with
  preview + restore). See `docs/`.

Docs: `docs/ARCHITECTURE.md` · `docs/FEATURE_GAP_ANALYSIS.md` ·
`docs/SECURITY.md` · `docs/IMPLEMENTATION_PLAN.md` · `docs/TEST_PLAN.md`

## License

- ဒီ ထုပ်ပိုးမှု (installer + လမ်းညွှန်): MIT
- အခြေခံ program `ai-memory`: MIT, © akitaonrails — အသေးစိတ် `NOTICE.md` ကြည့်
