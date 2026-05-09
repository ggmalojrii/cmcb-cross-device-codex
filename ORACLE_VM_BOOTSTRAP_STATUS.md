# Oracle VM Bootstrap Status

Generated: 2026-05-09

## Instance

- Provider: Oracle Cloud Always Free path
- Shape: `VM.Standard.E2.1.Micro`
- Image: Ubuntu selected in the OCI console for this recovered x86 VM path.
- Instance name: `instance-20260509-0409`
- Public IPv4: `192.9.157.198`
- Private IPv4: `10.0.0.59`
- Tailscale IPv4: `100.98.49.26`
- Tailscale hostname: `cmcb-oracle-free-worker`
- SSH user: `ubuntu`
- SSH private key: `C:\Users\marti\.ssh\oracle\ssh-key-2026-05-09.key`

## Oracle API Files

- Oracle API private key: `C:\Users\marti\.oracle\oci_api_key.pem`
- VM SSH public key source: `V:\public\ssh-key-2026-05-09.key.pub`

## Installed On VM

- Git
- curl
- unzip
- zip
- Python 3
- pip
- Node.js
- npm
- OpenJDK 21
- tmux
- rclone
- Syncthing
- Tailscale
- Codex CLI
- Gradle

## Services

- Tailscale: running and enrolled
- Syncthing: running as a user service

## Workspace Created

- `~/cmcb-work/projects`
- `~/cmcb-work/projects/cmcb-cross-device-codex`
- `~/cmcb-work/shared/CMCB-Shared/test_requests/desktop`
- `~/cmcb-work/shared/CMCB-Shared/test_requests/laptop`
- `~/cmcb-work/shared/CMCB-Shared/test_results/desktop`
- `~/cmcb-work/shared/CMCB-Shared/test_results/laptop`
- `~/cmcb-work/shared/CMCB-Shared/artifacts`
- `~/cmcb-work/shared/CMCB-Shared/logs`
- `~/cmcb-work/shared/CMCB-Shared/screenshots`
- `~/cmcb-work/shared/CMCB-Shared/handoffs`
- `~/cmcb-work/shared/CMCB-Shared/cmcb_sync`
- `~/cmcb-work/shared/CMCB-Shared/admin_install_requests`
- `~/cmcb-work/shared/CMCB-Shared/admin_install_results`

## Current State

- Tailscale is installed and enrolled.
- Tailscale login URL was used: `https://login.tailscale.com/a/f3fdd0b01b3da`
- The VM can ping the local aVM and desktop over tailnet.
- The GitHub repo `https://github.com/ggmalojrii/cmcb-cross-device-codex` is cloned at `~/cmcb-work/projects/cmcb-cross-device-codex`.

## Next Action

Use the VM as the Oracle Always Free worker, and add optional sync tooling if desired.
