param(
  [string]$SharedRoot = ""
)

$ErrorActionPreference = "Stop"

if (-not $SharedRoot) {
  if ($env:CMCB_SHARED_ROOT) {
    $SharedRoot = $env:CMCB_SHARED_ROOT
  }
  else {
    $SharedRoot = ".\shared\CMCB-Shared"
  }
}

$UserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
$MachinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
$ProcessPath = [System.Environment]::GetEnvironmentVariable("Path", "Process")
$env:Path = @($UserPath, $MachinePath, $ProcessPath) -join ";"

function Test-CommandReady {
  param([string]$Name)
  $Command = Get-Command $Name -ErrorAction SilentlyContinue
  if (-not $Command) {
    return [ordered]@{ present = $false; source = ""; usable = $false }
  }
  $Source = [string]$Command.Source
  $Usable = $true
  if (($Name -eq "python" -or $Name -eq "python3") -and $Source -like "*\WindowsApps\python*.exe") {
    $Usable = $false
  }
  return [ordered]@{ present = $true; source = $Source; usable = $Usable }
}

$Checks = [ordered]@{
  generated_at = (Get-Date).ToString("o")
  platform = [System.Environment]::OSVersion.VersionString
  git = Test-CommandReady "git"
  java = Test-CommandReady "java"
  node = Test-CommandReady "node"
  npm = Test-CommandReady "npm"
  codex = Test-CommandReady "codex"
  tailscale = Test-CommandReady "tailscale"
  syncthing = Test-CommandReady "syncthing"
  rclone = Test-CommandReady "rclone"
  terraform = Test-CommandReady "terraform"
  ssh = Test-CommandReady "ssh"
  python = Test-CommandReady "python"
  python3 = Test-CommandReady "python3"
  shared_folder_exists = Test-Path -LiteralPath $SharedRoot
}

$Checks["result"] = if ($Checks.git.usable -and ($Checks.python.usable -or $Checks.python3.usable) -and $Checks.shared_folder_exists) { "PASS" } else { "WARN" }

New-Item -ItemType Directory -Force -Path "reports" | Out-Null
$Checks | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 "reports\WINDOWS_TEST_NODE_VALIDATION_REPORT.json"
if (Test-Path -LiteralPath $SharedRoot) {
  New-Item -ItemType Directory -Force -Path (Join-Path $SharedRoot "logs") | Out-Null
  $Checks | ConvertTo-Json -Depth 10 | Set-Content -Encoding UTF8 (Join-Path $SharedRoot "logs\WINDOWS_TEST_NODE_VALIDATION_REPORT.json")
}
$Checks | ConvertTo-Json -Depth 10
