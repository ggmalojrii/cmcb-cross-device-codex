[CmdletBinding()]
param(
    [string]$DistroName = "Ubuntu-24.04",
    [string]$WorkRoot = "~/cmcb-work",
    [switch]$AllowAdminInstall,
    [switch]$AllowAptInstall,
    [switch]$SkipBootstrap
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$ReportsDir = Join-Path $PackageRoot "reports"
New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null
$ReportPath = Join-Path $ReportsDir "LOCAL_AVM_WSL_SETUP_REPORT.json"

function Write-Step {
    param([string]$Message)
    Write-Host "[local-avm] $Message"
}

function ConvertTo-WslPath {
    param([Parameter(Mandatory = $true)][string]$WindowsPath)
    $resolved = (Resolve-Path $WindowsPath).Path
    if ($resolved -match "^([A-Za-z]):\\(.*)$") {
        $drive = $matches[1].ToLowerInvariant()
        $tail = $matches[2] -replace "\\", "/"
        return "/mnt/$drive/$tail"
    }
    throw "Cannot convert path to WSL path: $resolved"
}

function Save-Report {
    param([hashtable]$Report)
    $Report.generated_at = (Get-Date).ToString("o")
    $Report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 -Path $ReportPath
}

function Invoke-NativeCapture {
    param([Parameter(Mandatory = $true)][scriptblock]$Command)
    $oldErrorActionPreference = $ErrorActionPreference
    try {
        $script:ErrorActionPreference = "Continue"
        $output = (& $Command 2>&1) | ForEach-Object { "$_" }
        return [pscustomobject]@{
            Output = ($output -join "`n")
            ExitCode = $LASTEXITCODE
        }
    }
    finally {
        $script:ErrorActionPreference = $oldErrorActionPreference
    }
}

$report = [ordered]@{
    packet_type = "CMCB_LOCAL_AVM_WSL_SETUP_REPORT"
    schema_version = "1.0"
    result = "INFO"
    generated_at = $null
    distro_name = $DistroName
    work_root = $WorkRoot
    package_root = $PackageRoot.Path
    allow_admin_install = [bool]$AllowAdminInstall
    allow_apt_install = [bool]$AllowAptInstall
    steps = @()
    next_action = ""
}

Write-Step "Checking WSL availability."
$wslCommand = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wslCommand) {
    $report.result = "BLOCKED"
    $report.steps += "wsl.exe was not found on PATH."
    $report.next_action = "Install or enable Windows Subsystem for Linux."
    Save-Report $report
    throw "wsl.exe was not found."
}

$wslListResult = Invoke-NativeCapture { wsl.exe -l -v }
$wslList = $wslListResult.Output -replace [char]0, ""
$wslListExit = $wslListResult.ExitCode

if ($wslListExit -ne 0 -or $wslList -match "not installed|--install") {
    $report.steps += "WSL is not installed or not initialized."
    if ($AllowAdminInstall) {
        Write-Step "Launching approved WSL install for $DistroName. Approve UAC if Windows asks."
        Start-Process -FilePath "wsl.exe" -ArgumentList @("--install", "-d", $DistroName) -Verb RunAs
        $report.result = "PENDING_REBOOT_OR_INITIALIZATION"
        $report.steps += "Launched wsl --install -d $DistroName with admin approval."
        $report.next_action = "Approve UAC, reboot if required, then run this script again."
        Save-Report $report
        Write-Step "Report written to $ReportPath"
        exit 20
    }

    $report.result = "BLOCKED"
    $report.next_action = "Run this script with -AllowAdminInstall to install WSL/Ubuntu after approval."
    Save-Report $report
    Write-Step "Blocked: WSL install requires explicit approval."
    Write-Step "Report written to $ReportPath"
    exit 20
}

$report.steps += "WSL command is available."
$report.steps += "wsl -l -v succeeded."

if ($wslList -notmatch [regex]::Escape($DistroName)) {
    $report.steps += "$DistroName is not installed."
    if ($AllowAdminInstall) {
        Write-Step "Launching approved Ubuntu distro install for $DistroName."
        Start-Process -FilePath "wsl.exe" -ArgumentList @("--install", "-d", $DistroName) -Verb RunAs
        $report.result = "PENDING_DISTRO_INITIALIZATION"
        $report.steps += "Launched distro install for $DistroName."
        $report.next_action = "Launch Ubuntu once, create the Linux user if prompted, then run this script again."
        Save-Report $report
        Write-Step "Report written to $ReportPath"
        exit 21
    }

    $report.result = "BLOCKED"
    $report.next_action = "Run this script with -AllowAdminInstall to install $DistroName after approval."
    Save-Report $report
    Write-Step "Blocked: $DistroName is not installed."
    Write-Step "Report written to $ReportPath"
    exit 21
}

Write-Step "$DistroName is installed. Checking it can run commands."
$trueResult = Invoke-NativeCapture { wsl.exe -d $DistroName -- bash -lc "printf ok" }
if ($trueResult.ExitCode -ne 0 -or $trueResult.Output -notmatch "ok") {
    $report.result = "BLOCKED"
    $report.steps += "$DistroName exists but did not run bash commands."
    $report.next_action = "Launch the distro once with 'wsl -d $DistroName' and complete first-run setup."
    Save-Report $report
    Write-Step "Blocked: distro first-run setup is probably incomplete."
    Write-Step "Report written to $ReportPath"
    exit 22
}

$report.steps += "$DistroName can run bash commands."

if ($SkipBootstrap) {
    $report.result = "PASS"
    $report.steps += "Bootstrap skipped by operator request."
    $report.next_action = "Run again without -SkipBootstrap when ready."
    Save-Report $report
    Write-Step "Report written to $ReportPath"
    exit 0
}

$wslScriptDir = ConvertTo-WslPath $ScriptDir
$bootstrap = "$wslScriptDir/bootstrap_vm.sh"
$approveApt = if ($AllowAptInstall) { "1" } else { "0" }

Write-Step "Running VM bootstrap inside $DistroName. Apt installs approved: $approveApt."
$bashCommand = @"
set -euo pipefail
export CMCB_WORK_ROOT="$WorkRoot"
export CMCB_APPROVE_APT_INSTALL="$approveApt"
bash "$bootstrap"
"@

$bootstrapResult = Invoke-NativeCapture { wsl.exe -d $DistroName -- bash -lc $bashCommand }
$bootstrapOutput = $bootstrapResult.Output
$bootstrapExit = $bootstrapResult.ExitCode
$report.steps += "Bootstrap exit code: $bootstrapExit"
$report.bootstrap_output_tail = (($bootstrapOutput -split "`n") | Select-Object -Last 40) -join "`n"

if ($bootstrapExit -ne 0) {
    $report.result = "FAIL"
    $report.next_action = "Review bootstrap_output_tail in the report and rerun after fixing the issue."
    Save-Report $report
    Write-Output $bootstrapOutput
    throw "Local aVM bootstrap failed with exit code $bootstrapExit."
}

$report.result = "PASS"
if ($AllowAptInstall) {
    $report.next_action = "Review Ubuntu validation report, then configure Tailscale/Codex auth through environment variables if needed."
} else {
    $report.next_action = "Run again with -AllowAptInstall after approving Ubuntu package installs."
}
Save-Report $report
Write-Output $bootstrapOutput
Write-Step "Report written to $ReportPath"
