#!/usr/bin/env bash
set -euo pipefail

BASE="${CMCB_WORK_ROOT:-$HOME/cmcb-work}"
REPO_DIR="$BASE/projects/cmcb-cross-device-codex"
SERVICE_SRC="$REPO_DIR/19_GENERATED_DEPLOYMENT/systemd/user/cmcb-oracle-worker.service"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_DST="$SERVICE_DIR/cmcb-oracle-worker.service"

mkdir -p "$SERVICE_DIR"
cp "$SERVICE_SRC" "$SERVICE_DST"

systemctl --user daemon-reload
systemctl --user enable --now cmcb-oracle-worker.service
systemctl --user --no-pager --full status cmcb-oracle-worker.service || true
