Write-Host "CMCB Windows test node bootstrap"

$Root = Join-Path (Get-Location) "shared\CMCB-Shared"
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

foreach ($d in $Dirs) {
  New-Item -ItemType Directory -Force -Path (Join-Path $Root $d) | Out-Null
}

Write-Host "Created shared folder tree at $Root"
Write-Host "Install Tailscale, Python, Git, Syncthing manually or through approved admin manifest."
Write-Host "Start agent example:"
Write-Host "python .\13_SCRIPTS\local_test_agent.py --node-id desktop --shared-root .\shared\CMCB-Shared"
