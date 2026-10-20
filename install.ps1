#Requires -Version 5.1
<#
  CursorMemo — secure installer for Windows (Funapp distro).

  Version 2.0 — production-grade installer:
    * Pinned upstream engine (ai-memory 3.1.1) — never a floating "latest".
    * The upstream installer script is verified against its published SHA-256
      checksum BEFORE it runs; the upstream script then verifies the binary
      archive the same way. A mismatch aborts everything.
    * Existing Cursor configuration is backed up before any change:
        %USERPROFILE%\.cursormemo\backups\<timestamp>\  (mcp.json, hooks.json)
    * Idempotent: safe to re-run. Modes: install (default), -Update,
      -Repair, -Uninstall, -Purge (with -Uninstall), -DryRun.
    * Uninstall NEVER deletes your memory data unless you pass -Purge.

  Prefer to review before running? Download-then-review works fine:
      Invoke-WebRequest https://cursormemo.funapp.live/install.ps1 -OutFile install.ps1
      notepad install.ps1   # read it, then:  .\install.ps1

  Upstream project (MIT): https://github.com/akitaonrails/ai-memory

  NOTE: this script mirrors install.sh v2. It has been statically reviewed;
  end-to-end execution on a real Windows machine is tracked as an open
  verification item in the project README.
#>
param(
  [switch]$Update,
  [switch]$Repair,
  [switch]$Uninstall,
  [switch]$Purge,
  [switch]$DryRun,
  [switch]$Version
)

$ErrorActionPreference = 'Stop'

$InstallerVersion = '2.0.0'
$PinnedEngine     = '3.1.1'
$ReleaseBase      = "https://github.com/akitaonrails/ai-memory/releases/download/v$PinnedEngine"
$CursorDir        = Join-Path $env:USERPROFILE '.cursor'
$BackupRoot       = Join-Path $env:USERPROFILE '.cursormemo\backups'

if ($Version) {
  Write-Host "CursorMemo installer $InstallerVersion (engine pinned: ai-memory $PinnedEngine)"
  exit 0
}

$Mode = 'install'
if ($Update)    { $Mode = 'update' }
if ($Repair)    { $Mode = 'repair' }
if ($Uninstall) { $Mode = 'uninstall' }

function Get-EngineVersion {
  $cmd = Get-Command ai-memory -ErrorAction SilentlyContinue
  if (-not $cmd) { return $null }
  try {
    $out = & ai-memory --version 2>$null
    if ($out -match '(\d+\.\d+\.\d+)') { return $Matches[1] }
  } catch { }
  return $null
}

function Backup-CursorConfig {
  $ts   = Get-Date -Format 'yyyyMMdd-HHmmss'
  $dest = Join-Path $BackupRoot $ts
  $made = $false
  foreach ($f in @('mcp.json','hooks.json')) {
    $src = Join-Path $CursorDir $f
    if (Test-Path $src) {
      if ($DryRun) {
        Write-Host "[dry-run] would back up $src -> $dest\"
      } else {
        New-Item -ItemType Directory -Force -Path $dest | Out-Null
        Copy-Item $src (Join-Path $dest $f) -Force
        $made = $true
      }
    }
  }
  if ($made) { Write-Host "Backed up existing Cursor config to: $dest" }
}

function Install-Engine {
  $current = Get-EngineVersion
  if ($current -eq $PinnedEngine -and $Mode -ne 'update') {
    Write-Host "ai-memory $PinnedEngine already installed - skipping download."
    return
  }
  Write-Host ""
  Write-Host "[engine] Downloading upstream installer for ai-memory v$PinnedEngine..."
  if ($DryRun) {
    Write-Host "[dry-run] would download $ReleaseBase/install.ps1 + .sha256, verify SHA-256, then run it with AI_MEMORY_VERSION=$PinnedEngine"
    return
  }
  $tmp = Join-Path $env:TEMP ("cursormemo-" + [guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Force -Path $tmp | Out-Null
  try {
    $script = Join-Path $tmp 'install.ps1'
    $sum    = Join-Path $tmp 'install.ps1.sha256'
    Invoke-WebRequest -UseBasicParsing -Uri "$ReleaseBase/install.ps1"        -OutFile $script
    Invoke-WebRequest -UseBasicParsing -Uri "$ReleaseBase/install.ps1.sha256" -OutFile $sum
    $expected = ((Get-Content -LiteralPath $sum -Raw).Trim() -split '\s+')[0].ToLowerInvariant()
    $actual   = (Get-FileHash -LiteralPath $script -Algorithm SHA256).Hash.ToLowerInvariant()
    if (-not $expected) { throw 'Checksum file was empty - aborting.' }
    if ($expected -ne $actual) {
      throw "CHECKSUM MISMATCH for upstream install.ps1 (expected $expected, got $actual). Aborting - nothing was run."
    }
    Write-Host 'Checksum verified: install.ps1 SHA-256 OK.'
    Write-Host 'Installing engine (upstream script verifies the binary archive the same way)...'
    $env:AI_MEMORY_VERSION = $PinnedEngine
    & $script
  } finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
  }
  # The upstream installer adds %LOCALAPPDATA%\Programs\ai-memory to the user PATH.
  $env:Path = [System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' +
              [System.Environment]::GetEnvironmentVariable('Path','User')
  if (-not (Get-Command ai-memory -ErrorAction SilentlyContinue)) {
    throw 'ai-memory is still not on PATH after install. Close this PowerShell window, open a new one, and run the installer again.'
  }
  $now = Get-EngineVersion
  if ($now -ne $PinnedEngine) {
    Write-Host "WARNING: installed ai-memory version reports '$now', expected '$PinnedEngine'." -ForegroundColor Yellow
  }
}

function Wire-Cursor {
  Write-Host ""
  Write-Host '[setup] Backing up existing Cursor configuration...'
  Backup-CursorConfig
  Write-Host '[setup] Wiring Cursor (MCP + hooks + skills, merged into existing config)...'
  if ($DryRun) { Write-Host '[dry-run] would run: ai-memory setup --agent cursor --yes'; return }
  $rc = 0
  try { & ai-memory setup --agent cursor --yes } catch { $rc = 1 }
  $mcp = Join-Path $CursorDir 'mcp.json'
  $wired = (Test-Path $mcp) -and ((Get-Content -LiteralPath $mcp -Raw) -match 'ai-memory')
  if ($wired) {
    if ($rc -ne 0) {
      Write-Host 'WARNING: setup reported an error (often: the background service could not start in this session), but Cursor IS wired. Restart Cursor to finish.' -ForegroundColor Yellow
    }
    Write-Host 'Verified: ~/.cursor/mcp.json contains the ai-memory entry.'
  } else {
    throw "Setup did not wire Cursor (no ai-memory entry in ~/.cursor/mcp.json). Your previous config is in $BackupRoot - restore it, or re-run with -Repair."
  }
}

function Find-DataDir {
  $candidates = @(
    $env:AI_MEMORY_HOME,
    (Join-Path $env:USERPROFILE '.local\share\ai-memory'),
    (Join-Path $env:USERPROFILE '.ai-memory'),
    (Join-Path $env:LOCALAPPDATA 'ai-memory'),
    (Join-Path $env:APPDATA 'ai-memory')
  )
  foreach ($d in $candidates) {
    if ($d -and (Test-Path $d)) { return $d }
  }
  return $null
}

function Do-Uninstall {
  Write-Host ""
  Write-Host '[uninstall] Backing up Cursor configuration first...'
  Backup-CursorConfig
  if (Get-Command ai-memory -ErrorAction SilentlyContinue) {
    if ($DryRun) { Write-Host '[dry-run] would run: ai-memory uninstall --apply' }
    else { try { & ai-memory uninstall --apply } catch { Write-Host 'WARNING: upstream uninstall reported an issue; continuing.' -ForegroundColor Yellow } }
  } else {
    Write-Host 'WARNING: ai-memory binary not found - nothing to unwire via the engine.' -ForegroundColor Yellow
  }
  $dataDir = Find-DataDir
  if ($dataDir) {
    if ($Purge) {
      if ($DryRun) {
        Write-Host "[dry-run] would DELETE memory data at: $dataDir"
      } else {
        $ans = Read-Host "Really delete ALL memory data at $dataDir ? Type YES to confirm"
        if ($ans -ne 'YES') { throw 'Purge not confirmed - memory preserved.' }
        Remove-Item -Recurse -Force $dataDir
        Write-Host "Memory data deleted: $dataDir"
      }
    } else {
      Write-Host "Memory data PRESERVED at: $dataDir"
      Write-Host 'To delete it too, re-run: .\install.ps1 -Uninstall -Purge'
    }
  } else {
    Write-Host 'No engine data directory found - nothing to purge.'
  }
  Write-Host "Uninstall complete. Cursor config backups remain in $BackupRoot"
}

# ---------------- main ----------------
Write-Host ''
Write-Host "=== CursorMemo installer v$InstallerVersion (engine: ai-memory v$PinnedEngine, pinned + checksum-verified) ===" -ForegroundColor Cyan

Write-Host ''
Write-Host '[preflight] Checking environment...'
$arch = $env:PROCESSOR_ARCHITECTURE
Write-Host "Platform: Windows / $arch"
if ($arch -notin @('AMD64','ARM64')) {
  Write-Host "WARNING: upstream provides a windows-x86_64 build; architecture '$arch' may not be supported." -ForegroundColor Yellow
}
if ((Test-Path $CursorDir) -or (Get-Command cursor -ErrorAction SilentlyContinue)) {
  Write-Host 'Cursor installation detected.'
} else {
  Write-Host 'WARNING: Cursor was not detected on this machine. The engine installs globally and Cursor can be wired later with -Repair.' -ForegroundColor Yellow
}

switch ($Mode) {
  'install' { Install-Engine; Wire-Cursor }
  'update'  { Install-Engine; Wire-Cursor }
  'repair'  {
    if (-not (Get-Command ai-memory -ErrorAction SilentlyContinue)) {
      throw 'ai-memory is not installed - run the installer without -Repair first.'
    }
    Wire-Cursor
  }
  'uninstall' { Do-Uninstall }
}

if ($Mode -ne 'uninstall') {
  Write-Host ''
  Write-Host 'Done! Next steps:' -ForegroundColor Green
  Write-Host '  1. Restart Cursor (or toggle the ai-memory server off/on in Settings -> MCP).'
  Write-Host '  2. Open a project and ask the agent: "What do you remember about this project?"'
  Write-Host ''
  Write-Host 'Uninstall anytime:  .\install.ps1 -Uninstall   (your memory is kept)'
}
Write-Host ''
