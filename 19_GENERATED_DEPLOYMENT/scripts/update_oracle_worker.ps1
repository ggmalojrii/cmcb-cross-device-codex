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
export CMCB_GIT_REPO_URL='$RepoUrl'
bash "`$HOME/cmcb-work/projects/cmcb-cross-device-codex/19_GENERATED_DEPLOYMENT/scripts/sync_oracle_worker.sh"
"@

& ssh.exe `
  -i $PrivateKeyPath `
  -o StrictHostKeyChecking=accept-new `
  -o ServerAliveInterval=30 `
  -o ServerAliveCountMax=2 `
  "ubuntu@$PublicIp" `
  $RemoteCommand
