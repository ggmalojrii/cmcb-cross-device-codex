#!/usr/bin/env bash
set -euo pipefail

HOSTNAME="${TAILSCALE_HOSTNAME:-cmcb-codex-vm}"
TAGS="${TAILSCALE_TAGS:-}"

if ! command -v tailscale >/dev/null 2>&1; then
  if [[ "${CMCB_APPROVE_APT_INSTALL:-0}" != "1" ]]; then
    echo "Tailscale is not installed. Set CMCB_APPROVE_APT_INSTALL=1 before installing packages."
    exit 2
  fi
  curl -fsSL https://tailscale.com/install.sh | sh
fi

if [[ "${CMCB_APPROVE_TAILSCALE_UP:-0}" != "1" ]]; then
  echo "Tailscale install check complete. Enrollment blocked until CMCB_APPROVE_TAILSCALE_UP=1."
  echo "Interactive alternative: sudo tailscale up --ssh --hostname \"$HOSTNAME\""
  exit 0
fi

if [[ -z "${TAILSCALE_AUTH_KEY:-}" ]]; then
  echo "TAILSCALE_AUTH_KEY is not set. Use interactive login or provide the key through environment."
  exit 3
fi

args=(up --auth-key "$TAILSCALE_AUTH_KEY" --hostname "$HOSTNAME" --ssh)
if [[ -n "$TAGS" ]]; then
  args+=(--advertise-tags "$TAGS")
fi

sudo tailscale "${args[@]}"
echo "Tailscale enrollment requested. Verify device in admin console and close any temporary public SSH ingress."

