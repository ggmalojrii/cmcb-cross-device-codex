#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE="${CMCB_WORK_ROOT:-$HOME/cmcb-work}"

echo "CMCB VM bootstrap starting."
echo "Work root: $BASE"

if [[ "${CMCB_APPROVE_APT_INSTALL:-0}" == "1" ]]; then
  sudo apt-get update
  sudo apt-get install -y git curl unzip zip python3 python3-pip nodejs npm openjdk-21-jdk tmux ca-certificates
else
  echo "Package install skipped. Set CMCB_APPROVE_APT_INSTALL=1 only after approval."
fi

bash "$SCRIPT_DIR/create_cmcb_tree.sh" "$BASE"
bash "$SCRIPT_DIR/setup_ssh.sh"
bash "$SCRIPT_DIR/setup_tailscale.sh" || true
bash "$SCRIPT_DIR/setup_codex.sh" || true
bash "$SCRIPT_DIR/validate_vm_environment.sh" "$BASE" || true

echo "CMCB VM bootstrap finished. Review reports before continuing."

