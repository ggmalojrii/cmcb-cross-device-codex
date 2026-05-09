[CmdletBinding()]
param(
    [string]$PublicIp = "",
    [string]$PrivateKeyPath = "",
    [string]$UserName = "ubuntu",
    [string]$RemoteCommand = ""
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$PackageRoot = Resolve-Path (Join-Path $ScriptDir "..\..")
$ReportsDir = Join-Path $PackageRoot "reports"
New-Item -ItemType Directory -Force -Path $ReportsDir | Out-Null

function Write-Info {
    param([string]$Message)
    Write-Host "[oracle-vm] $Message"
}

function Resolve-SharedRoot {
    if ($env:CMCB_SHARED_ROOT -and (Test-Path -LiteralPath $env:CMCB_SHARED_ROOT)) {
        return (Resolve-Path -LiteralPath $env:CMCB_SHARED_ROOT).Path
    }

    foreach ($Candidate in @(
        "V:\CMCB-Central\CMCB-Shared",
        (Join-Path $PackageRoot "shared\CMCB-Shared")
    )) {
        if (Test-Path -LiteralPath $Candidate) {
            return (Resolve-Path -LiteralPath $Candidate).Path
        }
    }

    return $null
}

function Read-OracleVmPacket {
    param([string]$SharedRoot)

    foreach ($Candidate in @(
        (Join-Path $SharedRoot "logs\oracle_vm_bootstrap_status.json"),
        (Join-Path $PackageRoot "ORACLE_VM_BOOTSTRAP_STATUS.json")
    )) {
        if ($Candidate -and (Test-Path -LiteralPath $Candidate)) {
            try {
                return [pscustomobject]@{
                    Path = $Candidate
                    Packet = (Get-Content -LiteralPath $Candidate -Raw | ConvertFrom-Json)
                }
            }
            catch {
                throw "Failed to parse Oracle VM packet at ${Candidate}: $($_.Exception.Message)"
            }
        }
    }

    return $null
}

$SharedRoot = Resolve-SharedRoot
$PacketInfo = if ($SharedRoot) { Read-OracleVmPacket -SharedRoot $SharedRoot } else { $null }

if (-not $PublicIp -and $PacketInfo -and $PacketInfo.Packet.public_ipv4) {
    $PublicIp = [string]$PacketInfo.Packet.public_ipv4
}

if (-not $PrivateKeyPath) {
    $DefaultKey = Join-Path $env:USERPROFILE ".ssh\oracle\ssh-key-2026-05-09.key"
    if ($PacketInfo -and $PacketInfo.Packet.PSObject.Properties.Name -contains "ssh_private_key") {
        $PrivateKeyPath = [string]$PacketInfo.Packet.ssh_private_key
    }
    else {
        $PrivateKeyPath = $DefaultKey
    }
}

if (-not $PublicIp) {
    throw "Public IP not provided and no live packet could resolve it. Pass -PublicIp or create V:\CMCB-Central\CMCB-Shared\logs\oracle_vm_bootstrap_status.json."
}

if (-not (Test-Path -LiteralPath $PrivateKeyPath)) {
    throw "Private key not found at $PrivateKeyPath"
}

$Report = [ordered]@{
    packet_type = "CMCB_ORACLE_VM_CONNECT_HELPER"
    result = "INFO"
    generated_at = (Get-Date).ToString("o")
    public_ip = $PublicIp
    private_key_path = $PrivateKeyPath
    user_name = $UserName
    remote_command = $RemoteCommand
    shared_root = $SharedRoot
    packet_source = if ($PacketInfo) { $PacketInfo.Path } else { $null }
}

$ReportPath = Join-Path $ReportsDir "ORACLE_VM_CONNECT_REPORT.json"
$Report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 -Path $ReportPath

if ($SharedRoot) {
    $SharedLogDir = Join-Path $SharedRoot "logs"
    New-Item -ItemType Directory -Force -Path $SharedLogDir | Out-Null
    $Report | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 -Path (Join-Path $SharedLogDir "oracle_vm_connect_report.json")
}

if (-not (Get-Command ssh.exe -ErrorAction SilentlyContinue)) {
    throw "ssh.exe was not found on PATH."
}

$SshArgs = @(
    "-i", $PrivateKeyPath,
    "-o", "StrictHostKeyChecking=accept-new",
    "-o", "ServerAliveInterval=30",
    "-o", "ServerAliveCountMax=2",
    "$UserName@$PublicIp"
)

Write-Info "Using packet: $($Report.packet_source)"
Write-Info "Connecting to $UserName@$PublicIp with key $PrivateKeyPath"
if ($RemoteCommand) {
    Write-Info "Running remote command."
    & ssh.exe @SshArgs $RemoteCommand
}
else {
    Write-Info "Opening interactive SSH session."
    & ssh.exe @SshArgs
}
