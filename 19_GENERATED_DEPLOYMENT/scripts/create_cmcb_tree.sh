#!/usr/bin/env bash
set -euo pipefail

BASE="${1:-$HOME/cmcb-work}"
SHARED="$BASE/shared/CMCB-Shared"

mkdir -p "$BASE/projects"
mkdir -p "$SHARED/test_requests/desktop" "$SHARED/test_requests/laptop"
mkdir -p "$SHARED/test_results/desktop" "$SHARED/test_results/laptop"
mkdir -p "$SHARED/artifacts" "$SHARED/logs" "$SHARED/screenshots" "$SHARED/handoffs" "$SHARED/cmcb_sync"
mkdir -p "$SHARED/admin_install_requests" "$SHARED/admin_install_results"

echo "CMCB tree ready at $SHARED"

