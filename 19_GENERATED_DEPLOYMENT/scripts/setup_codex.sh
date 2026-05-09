#!/usr/bin/env bash
set -euo pipefail

if ! command -v npm >/dev/null 2>&1; then
  if [[ "${CMCB_APPROVE_APT_INSTALL:-0}" != "1" ]]; then
    echo "npm is missing. Approve package install with CMCB_APPROVE_APT_INSTALL=1 before continuing."
    exit 2
  fi
  sudo apt-get update
  sudo apt-get install -y nodejs npm
fi

if command -v codex >/dev/null 2>&1; then
  codex --version || true
  echo "Codex CLI already present."
  exit 0
fi

if [[ "${CMCB_APPROVE_CODEX_INSTALL:-0}" != "1" ]]; then
  echo "Codex CLI install blocked until CMCB_APPROVE_CODEX_INSTALL=1."
  exit 3
fi

npm install -g @openai/codex
codex --version || true

