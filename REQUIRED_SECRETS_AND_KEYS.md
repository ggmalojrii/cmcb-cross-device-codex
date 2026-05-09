# Required Secrets And Keys

Do not commit real secrets. Do not place secrets in CMCB packets, shared folders, logs, Terraform files, or generated manifests.

Use environment variables, an OS keychain, a password manager, or provider-native secret handling.

## Cloud Provider

Required for Terraform or CLI deployment:

- Cloud provider token or credentials
- Region
- Project/account/subscription ID if the provider requires one
- Billing budget or spend guardrail

Environment placeholders:

```bash
export CLOUD_PROVIDER=""
export CLOUD_REGION=""
export CLOUD_VM_SIZE=""
export CLOUD_BUDGET_MONTHLY_USD=""
```

Provider examples:

```bash
export AWS_PROFILE=""
export AWS_REGION=""
export DIGITALOCEAN_TOKEN=""
export HCLOUD_TOKEN=""
export ARM_SUBSCRIPTION_ID=""
export OCI_TENANCY_OCID=""
export OCI_USER_OCID=""
export OCI_FINGERPRINT=""
export OCI_PRIVATE_KEY_PATH=""
export OCI_COMPARTMENT_OCID=""
export OCI_REGION=""
```

Keep the Oracle API private key outside `V:\CMCB-Central\CMCB-Shared` and any other synced/shared folder. Put it in a private local path under your user profile or another local-only directory.

## SSH

Required:

- SSH public key for VM access

Current local preparation:

- A dedicated public key was generated at `19_GENERATED_DEPLOYMENT/ssh/cmcb_codex_vm_ed25519.pub`.
- The private key remains outside the package at `~/.ssh/cmcb_codex_vm_ed25519`.
- Do not move the private key into Git, shared folders, CMCB packets, or logs.

Recommended:

```bash
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
```

Do not put private SSH keys in this package.

## Tailscale

Required for noninteractive enrollment:

```bash
export TAILSCALE_AUTH_KEY=""
export TAILSCALE_HOSTNAME="cmcb-codex-vm"
export TAILSCALE_TAGS="tag:codex-worker"
```

Safer alternative:

- Leave `TAILSCALE_AUTH_KEY` unset.
- Run `sudo tailscale up --ssh` interactively from provider console or approved SSH.

## OpenAI/Codex

Depending on Codex auth mode:

```bash
export OPENAI_API_KEY=""
export CODEX_AUTH_MODE="interactive"
```

If Codex uses browser or device login, do not store login cookies or auth artifacts in shared folders.

## Git

For private repos:

```bash
export GIT_REMOTE_URL=""
export GIT_SSH_COMMAND=""
```

Use SSH deploy keys or your normal SSH agent. Do not write tokens into clone URLs.

## Syncthing/Rclone

Syncthing:

```bash
export SYNCTHING_DEVICE_ID_DESKTOP=""
export SYNCTHING_DEVICE_ID_LAPTOP=""
export SYNCTHING_DEVICE_ID_VM=""
```

Rclone:

```bash
export RCLONE_CONFIG=""
```

Do not sync `.env`, private keys, cloud tokens, cookies, or password databases.

## Local Environment File

Use the generated placeholder file:

- `19_GENERATED_DEPLOYMENT/.env.example`

Copy it outside synced folders before adding real values.
