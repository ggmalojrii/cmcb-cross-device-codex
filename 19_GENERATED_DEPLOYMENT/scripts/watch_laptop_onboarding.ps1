param(
  [string]$Root = ".",
  [string]$SharedRoot = "",
  [string]$SmokeTestId = "test_88fd27fe96",
  [int]$IntervalSeconds = 10
)

$ErrorActionPreference = "Stop"

$ResolvedRoot = (Resolve-Path -LiteralPath $Root).Path
if ($SharedRoot) {
  $SharedRoot = (Resolve-Path -LiteralPath $SharedRoot).Path
}
else {
  $SharedRoot = Join-Path $ResolvedRoot "shared\CMCB-Shared"
}
$HandoffRoot = Join-Path $SharedRoot "handoffs\chatgpt-online"
$CheckinsRoot = Join-Path $HandoffRoot "checkins"
$LogsRoot = Join-Path $SharedRoot "logs"
$ResultsRoot = Join-Path $SharedRoot "test_results\laptop"
$DashboardPath = Join-Path $HandoffRoot "laptop_watch_status.json"

New-Item -ItemType Directory -Force -Path $CheckinsRoot, $LogsRoot, $ResultsRoot | Out-Null

function Write-JsonWithRetry {
  param(
    [Parameter(Mandatory = $true)]$Object,
    [Parameter(Mandatory = $true)][string]$Path
  )

  $TempPath = "$Path.tmp"
  $Object | ConvertTo-Json -Depth 30 | Set-Content -LiteralPath $TempPath -Encoding UTF8
  for ($Attempt = 1; $Attempt -le 5; $Attempt++) {
    try {
      Move-Item -LiteralPath $TempPath -Destination $Path -Force
      return
    }
    catch {
      if ($Attempt -eq 5) { throw }
      Start-Sleep -Milliseconds (200 * $Attempt)
    }
  }
}

while ($true) {
  $LatestCheckinPath = Join-Path $CheckinsRoot "latest_laptop_checkin.json"
  $LatestCheckin = $null
  if (Test-Path -LiteralPath $LatestCheckinPath) {
    try {
      $LatestCheckin = Get-Content -LiteralPath $LatestCheckinPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
      $LatestCheckin = [ordered]@{
        error = "latest_laptop_checkin.json could not be parsed"
        message = $_.Exception.Message
      }
    }
  }

  $SmokeResultPath = Join-Path $ResultsRoot "$SmokeTestId.json"
  $SmokeResult = $null
  if (Test-Path -LiteralPath $SmokeResultPath) {
    try {
      $SmokeResult = Get-Content -LiteralPath $SmokeResultPath -Raw -Encoding UTF8 | ConvertFrom-Json
    }
    catch {
      $SmokeResult = [ordered]@{
        error = "$SmokeTestId.json could not be parsed"
        message = $_.Exception.Message
      }
    }
  }

  $PendingRequestPath = Join-Path $SharedRoot "test_requests\laptop\$SmokeTestId.json"
  $ProcessedRequestPath = Join-Path $SharedRoot "test_requests\laptop\_processed\$SmokeTestId.json"

  $Status = [ordered]@{
    packet_type = "CMCB_LAPTOP_WATCH_STATUS"
    schema_version = "1.0"
    generated_at = (Get-Date).ToString("o")
    smoke_test_id = $SmokeTestId
    latest_checkin_present = [bool]$LatestCheckin
    latest_checkin = $LatestCheckin
    smoke_request_pending = Test-Path -LiteralPath $PendingRequestPath
    smoke_request_processed = Test-Path -LiteralPath $ProcessedRequestPath
    smoke_result_present = [bool]$SmokeResult
    smoke_result = $SmokeResult
    next_action = if (-not $LatestCheckin) {
      "Run laptop_onboarding.ps1 on the laptop."
    }
    elseif (-not $SmokeResult) {
      "Pair/sync CMCB-Shared and start the laptop local test agent."
    }
    else {
      "Review laptop smoke-test result."
    }
  }

  Write-JsonWithRetry -Object $Status -Path $DashboardPath
  Start-Sleep -Seconds $IntervalSeconds
}
