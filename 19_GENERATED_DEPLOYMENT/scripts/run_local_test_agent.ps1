param(
  [ValidateSet("desktop", "laptop")]
  [string]$NodeId = "desktop",
  [string]$SharedRoot = "",
  [switch]$Once
)

$ErrorActionPreference = "Stop"

$UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$MachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$ProcessPath = [System.Environment]::GetEnvironmentVariable("Path", "Process")
$env:Path = @($UserPath, $MachinePath, $ProcessPath) -join ";"

if (-not $SharedRoot) {
  if ($env:CMCB_SHARED_ROOT) {
    $SharedRoot = $env:CMCB_SHARED_ROOT
  }
  else {
    $SharedRoot = ".\shared\CMCB-Shared"
  }
}

function Get-UsablePython {
  foreach ($Name in @("python", "python3", "py")) {
    $Command = Get-Command $Name -ErrorAction SilentlyContinue
    if (-not $Command) { continue }
    $Source = [string]$Command.Source
    if ($Source -like "*\WindowsApps\python*.exe") { continue }
    return $Name
  }
  throw "No usable Python runtime found. Install Python 3 through the approved admin-install flow or manually."
}

$Python = Get-UsablePython
$GeneratedRoot = Split-Path $PSScriptRoot -Parent
$PackageRoot = Split-Path $GeneratedRoot -Parent
$AgentPath = Join-Path $PackageRoot "13_SCRIPTS\local_test_agent.py"

if (-not (Test-Path -LiteralPath $AgentPath)) {
  throw "local_test_agent.py not found at $AgentPath"
}

New-Item -ItemType Directory -Force -Path $SharedRoot | Out-Null

$Args = @($AgentPath, "--node-id", $NodeId, "--shared-root", $SharedRoot)
if ($Once) {
  $Args += "--once"
}

& $Python @Args
