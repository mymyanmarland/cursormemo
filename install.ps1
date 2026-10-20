#Requires -Version 5.1
<#
  CursorMemo — one-click installer for Windows (Funapp distro).

  What it does:
    1. Installs the upstream ai-memory program (MIT, by akitaonrails) if missing.
    2. Wires it to Cursor only: MCP + lifecycle hooks + agent skills.
    3. ai-memory then keeps a shared long-term memory for your Cursor projects:
       every session is captured, and the next session picks up where you left off.

  Usage (PowerShell):
      irm https://cursormemo.funapp.live/install.ps1 | iex

  Upstream project: https://github.com/akitaonrails/ai-memory
#>
$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '=== CursorMemo installer (Funapp distro) ===' -ForegroundColor Cyan
Write-Host ''

# 1. Install upstream ai-memory if it is not on PATH yet.
if (Get-Command ai-memory -ErrorAction SilentlyContinue) {
  Write-Host '[1/2] ai-memory is already installed, skipping download.'
} else {
  Write-Host '[1/2] Downloading and installing ai-memory (upstream release)...'
  irm https://github.com/akitaonrails/ai-memory/releases/latest/download/install.ps1 | iex
  # The upstream installer adds %LOCALAPPDATA%\Programs\ai-memory to the user PATH.
  # Refresh this session's PATH so ai-memory is usable right away.
  $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + `
              [System.Environment]::GetEnvironmentVariable('Path','User')
}

if (-not (Get-Command ai-memory -ErrorAction SilentlyContinue)) {
  Write-Host ''
  Write-Host 'ERROR: ai-memory is still not on PATH. Close this PowerShell window,' -ForegroundColor Red
  Write-Host 'open a new one, and run the installer again.' -ForegroundColor Red
  exit 1
}

# 2. Wire Cursor only (MCP + hooks + skills). --yes answers the prompt for you.
Write-Host '[2/2] Wiring Cursor (MCP + hooks + skills)...'
ai-memory setup --agent cursor --yes

Write-Host ''
Write-Host 'Done! Next steps:' -ForegroundColor Green
Write-Host '  1. Restart Cursor (or toggle the ai-memory server off/on in Settings -> MCP).'
Write-Host '  2. Open a project and ask the agent: "What do you remember about this project?"'
Write-Host ''
Write-Host 'Uninstall anytime with:  ai-memory uninstall --apply'
Write-Host ''
