#!/usr/bin/env bash
# CursorMemo — one-click installer for Linux / macOS / WSL2 (Funapp distro).
#
# What it does:
#   1. Installs the upstream ai-memory program (MIT, by akitaonrails) if missing.
#   2. Wires it to Cursor only: MCP + lifecycle hooks + agent skills.
#
# Usage:
#   curl -fsSL https://cursormemo.funapp.live/install.sh | sh
#
# Upstream project: https://github.com/akitaonrails/ai-memory
set -euo pipefail

echo ''
echo '=== CursorMemo installer (Funapp distro) ==='
echo ''

# 1. Install upstream ai-memory if it is not on PATH yet.
if command -v ai-memory >/dev/null 2>&1; then
  echo '[1/2] ai-memory is already installed, skipping download.'
else
  echo '[1/2] Downloading and installing ai-memory (upstream release)...'
  curl -fsSL https://github.com/akitaonrails/ai-memory/releases/latest/download/install.sh | sh
  # The upstream installer links ~/.local/bin/ai-memory.
  export PATH="$HOME/.local/bin:$PATH"
fi

if ! command -v ai-memory >/dev/null 2>&1; then
  echo ''
  echo 'ERROR: ai-memory is still not on PATH. Open a new terminal and re-run the installer.' >&2
  exit 1
fi

# 2. Wire Cursor only (MCP + hooks + skills). --yes answers the prompt for you.
echo '[2/2] Wiring Cursor (MCP + hooks + skills)...'
ai-memory setup --agent cursor --yes

echo ''
echo 'Done! Next steps:'
echo '  1. Restart Cursor (or toggle the ai-memory server off/on in Settings -> MCP).'
echo '  2. Open a project and ask the agent: "What do you remember about this project?"'
echo ''
echo 'Uninstall anytime with:  ai-memory uninstall --apply'
echo ''
