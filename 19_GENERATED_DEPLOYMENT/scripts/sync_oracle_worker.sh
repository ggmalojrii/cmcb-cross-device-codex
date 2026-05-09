#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${CMCB_GIT_REPO_URL:-https://github.com/ggmalojrii/cmcb-cross-device-codex.git}"
BASE="${CMCB_WORK_ROOT:-$HOME/cmcb-work}"
REPO_DIR="$BASE/projects/cmcb-cross-device-codex"
REPORT_DIR="$BASE/reports"
SHARED_ROOT="$BASE/shared/CMCB-Shared"
LOG_DIR="$SHARED_ROOT/logs"

mkdir -p "$BASE/projects" "$REPORT_DIR" "$LOG_DIR"
mkdir -p "$SHARED_ROOT/test_requests/cloud_vm" "$SHARED_ROOT/test_results/cloud_vm"

if [[ -d "$REPO_DIR/.git" ]]; then
  cd "$REPO_DIR"
  git pull --ff-only
else
  rm -rf "$REPO_DIR"
  git clone "$REPO_URL" "$REPO_DIR"
  cd "$REPO_DIR"
fi

COMMIT="$(git rev-parse --short HEAD)"
VALIDATION_PATH="$REPORT_DIR/ORACLE_VM_ENVIRONMENT_VALIDATION.json"
python3 13_SCRIPTS/validate_environment.py

if [[ -f "$VALIDATION_PATH" ]]; then
  cp "$VALIDATION_PATH" "$LOG_DIR/ORACLE_VM_ENVIRONMENT_VALIDATION.json" 2>/dev/null || true
fi

cat <<EOF
{
  "result": "PASS",
  "repo_dir": "$REPO_DIR",
  "commit": "$COMMIT",
  "validation_path": "$VALIDATION_PATH"
}
EOF
