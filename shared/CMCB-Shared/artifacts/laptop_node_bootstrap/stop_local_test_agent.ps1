param(
  [string]$PidFile = ".\shared\CMCB-Shared\logs\desktop_agent.pid"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path -LiteralPath $PidFile)) {
  Write-Host "PID file not found: $PidFile"
  exit 0
}

$AgentPid = (Get-Content -LiteralPath $PidFile -Raw).Trim()
if (-not $AgentPid) {
  Write-Host "PID file is empty: $PidFile"
  exit 0
}

$Process = Get-Process -Id ([int]$AgentPid) -ErrorAction SilentlyContinue
if (-not $Process) {
  Write-Host "No running process found for PID $AgentPid"
  exit 0
}

Stop-Process -Id $Process.Id
Write-Host "Stopped local test agent PID $AgentPid"

