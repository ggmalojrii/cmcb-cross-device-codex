#!/usr/bin/env bash
set -euo pipefail

echo "CMCB cloud VM bootstrap"
mkdir -p "$HOME/cmcb-work/projects" "$HOME/cmcb-work/shared/CMCB-Shared"/{test_requests/{desktop,laptop},test_results/{desktop,laptop},artifacts,logs,screenshots,handoffs,cmcb_sync,admin_install_requests,admin_install_results}

if command -v apt >/dev/null 2>&1; then
  echo "Detected apt. Installing base packages requires sudo."
  sudo apt update
  sudo apt install -y git curl unzip zip python3 python3-pip nodejs npm openjdk-21-jdk tmux
fi

if command -v npm >/dev/null 2>&1; then
  echo "Installing Codex CLI with npm if not already present."
  if ! command -v codex >/dev/null 2>&1; then
    npm i -g @openai/codex
  fi
fi

echo "Bootstrap complete. Next: install/login Tailscale, clone project, extract CMCB drop-in, run Codex."
