param(
  [string]$InstallRoot = "$env:USERPROFILE\Documents\CMCB\laptop_node",
  [switch]$StartAgent
)

$ErrorActionPreference = "Stop"

$BaseUrl = "https://salvation-securities-makes-steps.trycloudflare.com"
$ZipUrl = "$BaseUrl/laptop_node_bootstrap.zip"
$CheckinUrl = "$BaseUrl/api/laptop-checkin"
$ExpectedSha256 = "dd3177d19b1bb7eed3f69bd451d3fee88b45531a694fa9e9d283503280731b59"

function Refresh-Path {
  $UserPath = [Environment]::GetEnvironmentVariable("Path", "User")
  $MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
  $ProcessPath = [Environment]::GetEnvironmentVariable("Path", "Process")
  $env:Path = @($UserPath, $MachinePath, $ProcessPath) -join ";"
}

function Send-Checkin {
  param(
    [string]$Stage,
    [string]$Result = "INFO",
    [hashtable]$Details = @{}
  )

  $Payload = [ordered]@{
    node_id = "laptop"
    stage = $Stage
    result = $Result
    hostname = $env:COMPUTERNAME
    timestamp = (Get-Date).ToString("o")
    details = $Details
  }

  try {
    Invoke-RestMethod -Uri $CheckinUrl -Method Post -ContentType "application/json" -Body ($Payload | ConvertTo-Json -Depth 10) | Out-Null
  }
  catch {
    Write-Host "Check-in failed for stage '$Stage': $($_.Exception.Message)"
  }
}

trap {
  Send-Checkin -Stage "error" -Result "FAIL" -Details @{ message = $_.Exception.Message }
  break
}

function Ensure-WingetPackage {
  param(
    [string]$Id,
    [string]$CommandName,
    [switch]$NeedsSystemInstall
  )

  Refresh-Path
  if (Get-Command $CommandName -ErrorAction SilentlyContinue) {
    Write-Host "$CommandName already present."
    Send-Checkin -Stage "tool_present" -Result "PASS" -Details @{ command = $CommandName; package = $Id }
    return
  }

  if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    throw "winget is required but was not found."
  }

  $Args = @("install", "--id", $Id, "-e", "--silent", "--accept-source-agreements", "--accept-package-agreements")
  if (-not $NeedsSystemInstall) {
    $Args += @("--scope", "user")
  }

  Write-Host "Installing $Id with winget..."
  Send-Checkin -Stage "tool_install_start" -Result "INFO" -Details @{ command = $CommandName; package = $Id }
  & winget @Args
  Refresh-Path
  Send-Checkin -Stage "tool_install_done" -Result "PASS" -Details @{ command = $CommandName; package = $Id }
}

New-Item -ItemType Directory -Force -Path $InstallRoot | Out-Null
$ZipPath = Join-Path $InstallRoot "laptop_node_bootstrap.zip"

Send-Checkin -Stage "start" -Result "INFO" -Details @{ install_root = $InstallRoot }
Write-Host "Downloading laptop bootstrap ZIP..."
Invoke-WebRequest -UseBasicParsing -Uri $ZipUrl -OutFile $ZipPath
Send-Checkin -Stage "download_done" -Result "PASS" -Details @{ zip_path = $ZipPath }

$ActualSha256 = (Get-FileHash -LiteralPath $ZipPath -Algorithm SHA256).Hash.ToLowerInvariant()
if ($ActualSha256 -ne $ExpectedSha256) {
  throw "SHA256 mismatch. Expected $ExpectedSha256 but got $ActualSha256"
}
Write-Host "SHA256 verified: $ActualSha256"
Send-Checkin -Stage "sha256_verified" -Result "PASS" -Details @{ sha256 = $ActualSha256 }

$ExtractPath = Join-Path $InstallRoot "bootstrap"
if (Test-Path -LiteralPath $ExtractPath) {
  Remove-Item -LiteralPath $ExtractPath -Recurse -Force
}
New-Item -ItemType Directory -Force -Path $ExtractPath | Out-Null
Expand-Archive -LiteralPath $ZipPath -DestinationPath $ExtractPath -Force
Send-Checkin -Stage "extract_done" -Result "PASS" -Details @{ extract_path = $ExtractPath }

Ensure-WingetPackage -Id "Python.Python.3.12" -CommandName "python"
Ensure-WingetPackage -Id "Syncthing.Syncthing" -CommandName "syncthing"
Ensure-WingetPackage -Id "Rclone.Rclone" -CommandName "rclone"
Ensure-WingetPackage -Id "Tailscale.Tailscale" -CommandName "tailscale" -NeedsSystemInstall

$SharedRoot = Join-Path $InstallRoot "shared\CMCB-Shared"
Push-Location $ExtractPath
try {
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\setup_windows_test_node.ps1" -NodeId laptop -SharedRoot $SharedRoot
  powershell -NoProfile -ExecutionPolicy Bypass -File ".\validate_windows_test_node.ps1" -SharedRoot $SharedRoot
  Send-Checkin -Stage "validation_done" -Result "PASS" -Details @{ shared_root = $SharedRoot }
}
finally {
  Pop-Location
}

Write-Host ""
Write-Host "Tailscale status:"
tailscale status
$TailscaleIp = ""
try {
  $TailscaleIp = (tailscale ip -4 2>$null | Select-Object -First 1)
}
catch {
  $TailscaleIp = ""
}
Send-Checkin -Stage "tailscale_status_checked" -Result "INFO" -Details @{ tailscale_ipv4 = $TailscaleIp }
Write-Host ""
Write-Host "If Tailscale is logged out, run:"
Write-Host "  tailscale up"
Write-Host ""

if ($StartAgent) {
  Send-Checkin -Stage "agent_start_requested" -Result "INFO" -Details @{ shared_root = $SharedRoot }
  Push-Location $ExtractPath
  try {
    powershell -NoProfile -ExecutionPolicy Bypass -File ".\run_local_test_agent.ps1" -NodeId laptop -SharedRoot $SharedRoot
  }
  finally {
    Pop-Location
  }
}
else {
  Send-Checkin -Stage "complete_agent_not_started" -Result "PASS" -Details @{ extract_path = $ExtractPath; shared_root = $SharedRoot }
  Write-Host "Laptop bootstrap complete. To start the laptop agent later:"
  Write-Host "  cd `"$ExtractPath`""
  Write-Host "  powershell -ExecutionPolicy Bypass -File .\run_local_test_agent.ps1 -NodeId laptop -SharedRoot `"$SharedRoot`""
}
