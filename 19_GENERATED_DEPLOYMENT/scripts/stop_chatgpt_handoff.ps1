param(
  [string]$LogsDir = ""
)

$ErrorActionPreference = "Stop"

if (-not $LogsDir) {
  if ($env:CMCB_SHARED_ROOT) {
    $LogsDir = Join-Path $env:CMCB_SHARED_ROOT "logs"
  }
  else {
    $LogsDir = ".\shared\CMCB-Shared\logs"
  }
}

foreach ($Name in @("chatgpt_handoff_tunnel.pid", "chatgpt_handoff_server.pid")) {
  $PidPath = Join-Path $LogsDir $Name
  if (-not (Test-Path -LiteralPath $PidPath)) {
    Write-Host "PID file not found: $PidPath"
    continue
  }

  $ProcessId = (Get-Content -LiteralPath $PidPath -Raw).Trim()
  if (-not $ProcessId) {
    Write-Host "PID file empty: $PidPath"
    continue
  }

  $Process = Get-Process -Id ([int]$ProcessId) -ErrorAction SilentlyContinue
  if (-not $Process) {
    Write-Host "No running process for PID $ProcessId"
    continue
  }

  Stop-Process -Id $Process.Id
  Write-Host "Stopped $($Process.ProcessName) PID $ProcessId"
}
