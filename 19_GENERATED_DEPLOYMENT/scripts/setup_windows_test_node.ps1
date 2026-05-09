param(
  [ValidateSet("desktop", "laptop")]
  [string]$NodeId = "desktop",
  [string]$SharedRoot = ".\shared\CMCB-Shared"
)

$ErrorActionPreference = "Stop"

$Dirs = @(
  "test_requests\desktop",
  "test_requests\laptop",
  "test_results\desktop",
  "test_results\laptop",
  "artifacts",
  "logs",
  "screenshots",
  "handoffs",
  "cmcb_sync",
  "admin_install_requests",
  "admin_install_results"
)

foreach ($Dir in $Dirs) {
  New-Item -ItemType Directory -Force -Path (Join-Path $SharedRoot $Dir) | Out-Null
}

$Report = [ordered]@{
  result = "FOLDER_TREE_READY"
  node_id = $NodeId
  shared_root = (Resolve-Path $SharedRoot).Path
  admin_installs_run = $false
  local_agent_started = $false
  next_step = "Run validate_windows_test_node.ps1, then run_local_test_agent.ps1 only when approved."
  timestamp = (Get-Date).ToString("o")
}

New-Item -ItemType Directory -Force -Path "reports" | Out-Null
$Report | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 "reports\WINDOWS_TEST_NODE_SETUP_REPORT.json"
$Report | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $SharedRoot "logs\WINDOWS_TEST_NODE_SETUP_REPORT.json")
$Report | ConvertTo-Json -Depth 10

