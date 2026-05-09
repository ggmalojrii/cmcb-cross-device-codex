#!/usr/bin/env bash
set -euo pipefail

BASE="${1:-${CMCB_WORK_ROOT:-$HOME/cmcb-work}}"
SHARED="$BASE/shared/CMCB-Shared"
REPORT_DIR="$BASE/reports"
mkdir -p "$REPORT_DIR" "$SHARED/logs" 2>/dev/null || true

check_cmd() {
  if command -v "$1" >/dev/null 2>&1; then
    printf 'true'
  else
    printf 'false'
  fi
}

shared_exists=false
if [[ -d "$SHARED" ]]; then
  shared_exists=true
fi

cat > "$REPORT_DIR/ENVIRONMENT_VALIDATION_REPORT.json" <<EOF
{
  "result": "INFO",
  "work_root": "$BASE",
  "shared_root": "$SHARED",
  "git": $(check_cmd git),
  "java": $(check_cmd java),
  "python3": $(check_cmd python3),
  "node": $(check_cmd node),
  "npm": $(check_cmd npm),
  "codex": $(check_cmd codex),
  "tailscale": $(check_cmd tailscale),
  "syncthing": $(check_cmd syncthing),
  "rclone": $(check_cmd rclone),
  "shared_folder_exists": $shared_exists
}
EOF

cp "$REPORT_DIR/ENVIRONMENT_VALIDATION_REPORT.json" "$SHARED/logs/ENVIRONMENT_VALIDATION_REPORT.json" 2>/dev/null || true
cat "$REPORT_DIR/ENVIRONMENT_VALIDATION_REPORT.json"

