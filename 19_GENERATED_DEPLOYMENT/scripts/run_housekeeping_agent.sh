#!/usr/bin/env bash
set -euo pipefail

BASE="${CMCB_WORK_ROOT:-$HOME/cmcb-work}"
REPO_DIR="$BASE/projects/cmcb-cross-device-codex"
SHARED_ROOT="$BASE/shared/CMCB-Shared"
HANDOFF_DIR="$SHARED_ROOT/handoffs/chatgpt-online"

export PATH="$HOME/bin:$PATH"

cd "$REPO_DIR"
exec python3 13_SCRIPTS/housekeeping_agent.py --node-id cloud_vm --shared-root "$SHARED_ROOT" --repo-dir "$REPO_DIR" --handoff-dir "$HANDOFF_DIR"
