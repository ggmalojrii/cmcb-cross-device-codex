#!/usr/bin/env bash
set -euo pipefail

BASE="${CMCB_WORK_ROOT:-$HOME/cmcb-work}"
REPO_DIR="$BASE/projects/cmcb-cross-device-codex"
SHARED_ROOT="$BASE/shared/CMCB-Shared"

cd "$REPO_DIR"
exec python3 13_SCRIPTS/oracle_worker_agent.py --node-id cloud_vm --shared-root "$SHARED_ROOT" --repo-dir "$REPO_DIR"
