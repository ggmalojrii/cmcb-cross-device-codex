[CmdletBinding()]
param(
    [string]$PublicIp = "192.9.157.198",
    [string]$PrivateKeyPath = "C:\Users\marti\.ssh\oracle\ssh-key-2026-05-09.key",
    [string]$RepoUrl = "https://github.com/ggmalojrii/cmcb-cross-device-codex.git"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
if (-not (Test-Path -LiteralPath $PrivateKeyPath)) {
    throw "Private key not found at $PrivateKeyPath"
}

if (-not (Get-Command ssh.exe -ErrorAction SilentlyContinue)) {
    throw "ssh.exe was not found on PATH."
}

$RemoteCommand = @"
set -euo pipefail
REPO_DIR="`$HOME/cmcb-work/projects/cmcb-cross-device-codex"
if [ -d "`$REPO_DIR/.git" ]; then
  cd "`$REPO_DIR"
  git pull --ff-only
else
  rm -rf "`$REPO_DIR"
  git clone '$RepoUrl' "`$REPO_DIR"
  cd "`$REPO_DIR"
fi
python3 13_SCRIPTS/validate_environment.py
"@

& ssh.exe `
  -i $PrivateKeyPath `
  -o StrictHostKeyChecking=accept-new `
  -o ServerAliveInterval=30 `
  -o ServerAliveCountMax=2 `
  "ubuntu@$PublicIp" `
  $RemoteCommand
