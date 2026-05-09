#!/usr/bin/env bash
set -euo pipefail

SSH_DIR="${HOME}/.ssh"
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [[ -n "${SSH_PUBLIC_KEY:-}" ]]; then
  touch "$SSH_DIR/authorized_keys"
  chmod 600 "$SSH_DIR/authorized_keys"
  if ! grep -qxF "$SSH_PUBLIC_KEY" "$SSH_DIR/authorized_keys"; then
    printf '%s\n' "$SSH_PUBLIC_KEY" >> "$SSH_DIR/authorized_keys"
  fi
  echo "Approved SSH public key present in authorized_keys."
else
  echo "SSH_PUBLIC_KEY is not set. No key was added."
fi

echo "Do not place private keys in this package or shared folders."

