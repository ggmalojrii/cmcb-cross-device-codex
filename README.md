# CMCB-v18.27-cross-device-vm-codex-environment-setup

Date: 2026-05-07

## Purpose

Set up a cross-device Codex worker environment.

- Cloud VM runs Codex as the main worker/orchestrator.
- Desktop/laptop act as optional local test nodes.
- iPhone/iPad act as control/review clients.
- Tailscale/private networking connects devices.
- Git handles source.
- Syncthing/rclone/shared folders handle logs/artifacts.
- CMCB v18.26 handles Codex↔ChatGPT state.
- v18.27 adds VM↔desktop/laptop test request/result packets and admin-install guardrails.

## Important admin-install boundary

Codex can be instructed to install programs/apps with admin privileges only through explicit, user-approved manifests and elevation prompts. It should never silently bypass UAC/sudo, install unknown software, ignore checksums, or store credentials in packets/logs.

## Main entrypoints

- `00_START_HERE/START_HERE.md`
- `AGENTS.md`
- `04_CLOUD_VM/CLOUD_VM_SETUP.md`
- `05_WINDOWS_DESKTOP_LAPTOP/WINDOWS_TEST_NODE_SETUP.md`
- `11_ADMIN_INSTALLS/ADMIN_PRIVILEGE_INSTALL_PROTOCOL.md`
- `13_SCRIPTS/vm_orchestrator.py`
- `13_SCRIPTS/local_test_agent.py`
- `13_SCRIPTS/admin_install_manager.py`

## Current live state

- Oracle worker repo clone: `~/cmcb-work/projects/cmcb-cross-device-codex`
- Oracle VM helper from Windows: `19_GENERATED_DEPLOYMENT/scripts/connect_oracle_vm.ps1`
- Central shared root: `V:\CMCB-Central\CMCB-Shared`
- Use Git for source and keep secrets out of the repo.

## Recommended workflow

1. Use the Windows SSH helper to reach the Oracle worker.
2. Make changes in this repo clone first.
3. Push to GitHub after each meaningful checkpoint.
4. Pull on the Oracle VM before running validation there.
5. Keep credentials, private keys, and `.env` files local only.

## Worker refresh

- Windows launcher: `19_GENERATED_DEPLOYMENT/scripts/update_oracle_worker.ps1`
- VM refresh script: `19_GENERATED_DEPLOYMENT/scripts/sync_oracle_worker.sh`
- The refresh loop pulls the latest repo state and runs `13_SCRIPTS/validate_environment.py` on the Oracle worker.

## Cloud worker packets

- `13_SCRIPTS/oracle_worker_agent.py` handles `cloud_vm` packet requests.
- `13_SCRIPTS/vm_orchestrator.py` can now create `cloud_vm` requests and collect cloud results.
- `19_GENERATED_DEPLOYMENT/scripts/create_cmcb_tree.sh` now creates `cloud_vm` request/result folders.
- `19_GENERATED_DEPLOYMENT/scripts/install_oracle_worker_service.sh` installs the persistent Oracle worker service.
