$ManifestPath = "11_ADMIN_INSTALLS\ADMIN_INSTALL_MANIFEST.json"
if (!(Test-Path $ManifestPath)) {
  $ManifestPath = "ADMIN_INSTALL_MANIFEST.json"
}
if (!(Test-Path $ManifestPath)) {
  Write-Error "ADMIN_INSTALL_MANIFEST.json not found"
  exit 1
}

$Manifest = Get-Content $ManifestPath -Raw | ConvertFrom-Json
$Policy = $Manifest.global_policy

New-Item -ItemType Directory -Force -Path "reports" | Out-Null
New-Item -ItemType Directory -Force -Path "shared\CMCB-Shared\admin_install_results" | Out-Null

if (-not $Policy.allow_admin_actions) {
  $Report = @{
    result = "BLOCKED"
    blocked_only_by = @("allow_admin_actions=false")
    timestamp = (Get-Date).ToString("o")
  }
  $Report | ConvertTo-Json -Depth 10 | Set-Content "reports\ADMIN_INSTALL_REPORT.json"
  $Report | ConvertTo-Json -Depth 10 | Set-Content "shared\CMCB-Shared\admin_install_results\ADMIN_INSTALL_REPORT.json"
  Write-Host "Blocked: allow_admin_actions=false"
  exit 1
}

$Results = @()

foreach ($Installer in $Manifest.windows_installers) {
  if (-not $Installer.enabled) { continue }

  if ($Installer.method -eq "winget") {
    $Args = @("install", "--id", $Installer.package_id, "-e", "--accept-source-agreements", "--accept-package-agreements")
    foreach ($a in $Installer.arguments) { $Args += $a }

    Write-Host "Requesting admin install via winget: $($Installer.package_id)"
    Write-Host "UAC approval may be required. Do not approve if this is unexpected."

    $ArgString = $Args -join " "
    $Proc = Start-Process -FilePath "winget" -ArgumentList $ArgString -Verb RunAs -Wait -PassThru

    $Results += @{
      id = $Installer.id
      method = "winget"
      package_id = $Installer.package_id
      exit_code = $Proc.ExitCode
    }

    foreach ($cmd in $Installer.post_install_validation_commands) {
      Write-Host "Validation command: $cmd"
      cmd /c $cmd
    }
  }
  elseif ($Installer.method -eq "manual_installer") {
    $Results += @{
      id = $Installer.id
      result = "BLOCKED"
      reason = "manual_installer download/execution must be staged and checksum-validated before admin run"
    }
  }
  else {
    $Results += @{
      id = $Installer.id
      result = "BLOCKED"
      reason = "unsupported installer method"
    }
  }
}

$Report = @{
  result = "DONE"
  timestamp = (Get-Date).ToString("o")
  results = $Results
}

$Report | ConvertTo-Json -Depth 10 | Set-Content "reports\ADMIN_INSTALL_REPORT.json"
$Report | ConvertTo-Json -Depth 10 | Set-Content "shared\CMCB-Shared\admin_install_results\ADMIN_INSTALL_REPORT.json"
Write-Host "Admin install report written."
