# CMCB v18.27 Cross-Device Codex Setup Plan

Generated: 2026-05-08
Package date: 2026-05-07

## Scope

This is a planning and template-generation pass for the CMCB v18.27 cross-device Codex environment. No paid cloud resources, Terraform apply, admin installs, public port exposure, destructive changes, credential capture, or secret writes are approved by this file.

## Source Documents Read

- `00_START_HERE/START_HERE.md`
- `AGENTS.md`
- `NODE_REGISTRY.json`
- `03_ARCHITECTURE/CROSS_DEVICE_ARCHITECTURE.md`
- `04_CLOUD_VM/CLOUD_VM_SETUP.md`
- `05_WINDOWS_DESKTOP_LAPTOP/WINDOWS_TEST_NODE_SETUP.md`
- `08_SHARED_STORAGE_SYNC/SHARED_STORAGE_PLAN.md`
- `09_TEST_NODE_PROTOCOL/TEST_NODE_PROTOCOL.md`
- `11_ADMIN_INSTALLS/ADMIN_PRIVILEGE_INSTALL_PROTOCOL.md`
- `14_SECURITY/SECURITY_DEFAULTS.md`
- `13_SCRIPTS/validate_environment.py`

## Package Inventory

- Package root: `CMCB-v18.27-cross-device-vm-codex-environment-setup`
- Files: 55
- Directories: 22
- Total extracted size: about 54.53 MB
- Markdown docs: 18
- Python scripts: 12
- JSON files: 9
- PowerShell/shell scripts: 3
- Embedded ZIP artifacts: 4

Embedded CMCB artifacts present:

- `CMCB-v18.24-codex-chatgpt-ops-sync-bridge-platform-superzip.zip`
- `CMCB-v18.25-speaker-origin-verification-router-superzip.zip`
- `CMCB-v18.26-bidirectional-cmcb-sync-codex-package.zip`
- `CMCB-v18.26-bidirectional-cmcb-sync-codex-package-codex-dropin.zip`
- `CMCB-v18.26-summary.json`

## Current Desktop Status

Already detected on this Windows desktop:

- Git
- Java
- Node
- Codex CLI
- OpenSSH client
- Windows PowerShell

Missing or not ready:

- Real Python runtime on PATH. `python` and `python3` resolve to Microsoft Store aliases, not a usable interpreter in this session.
- npm
- Tailscale
- Syncthing
- rclone
- Terraform
- `shared/CMCB-Shared` under the extracted package

## Target Topology

- Cloud VM: Codex orchestrator, build worker, server test host, artifact packager. Free-first mirror path now points to Oracle Always Free when you want a cloud VM without paying.
- Desktop: optional local test node for Windows/GPU/Minecraft/client checks.
- Laptop: optional secondary local test node.
- iPhone/iPad: review/control clients only, usually SSH or dashboard review through Tailscale.
- Central Chat/CMCB: command and state relay through sync packets.

## Deployment Phases

1. Approve missing configuration.
   - Cloud provider
   - Region
   - VM size and monthly budget
   - SSH public key
   - Tailscale enrollment method
   - Git repo/workspace source
   - Syncthing or rclone preference
   - If cloud should stay free, prefer Oracle Always Free and an A1 Flex shape.

2. Prepare cloud VM infrastructure.
   - Use Ubuntu 24.04 LTS.
   - Keep public ports closed by default.
   - If provider console access is not enough for first bootstrap, approve temporary SSH ingress to a narrow trusted CIDR only.
   - Do not store Tailscale auth keys or cloud tokens in Terraform files.

3. Bootstrap VM tooling.
   - Install base packages only after approval: Git, curl, unzip, zip, Python 3, Node/npm, Java 21, tmux.
   - Install Tailscale.
   - Bring VM into tailnet only with an environment-provided auth key or interactive login.
   - Install Codex CLI after Node/npm is available.

4. Set up CMCB folders.
   - Create `~/cmcb-work/projects`.
   - Create `~/cmcb-work/shared/CMCB-Shared`.
   - Create request/result/artifact/log/screenshot/handoff/sync/admin-result folders.

5. Set up source workspace.
   - Use Git for source.
   - Clone approved repo(s) into `~/cmcb-work/projects`.
   - Keep secrets in environment variables or user secret stores, not packets/logs.

6. Set up shared artifacts/log sync.
   - Pick Syncthing or rclone.
   - Sync only artifacts/logs/packets.
   - Do not sync private keys, tokens, cookies, passwords, or `.env` files.

7. Set up desktop/laptop local nodes.
   - Create local shared folder tree.
   - Install required tools only after admin-install approval.
   - Start `local_test_agent.py` only when explicitly requested.
   - Agent must process only allowlisted packet test types.

8. Set up iDevice control/review.
   - Install Tailscale on iPhone/iPad.
   - Use mobile SSH/review tools against tailnet addresses.
   - No heavy worker tasks on iDevices.

9. Validate and operate.
   - Run VM validation script.
   - Run desktop/laptop validation scripts.
   - Create sample `file_inventory` request.
   - Confirm desktop/laptop result packets land in `test_results/<node>`.

## Known Drift To Resolve

The original `12_TEMPLATES/CMCB_TEST_REQUEST.schema.json` lists test types that do not match the local agent allowlist. The protocol and agent agree on:

- `file_inventory`
- `artifact_presence`
- `minecraft_client_manual`
- `minecraft_log_collect`
- `visual_manual`
- `custom_script` only if explicitly allowlisted

A generated aligned schema is provided at `19_GENERATED_DEPLOYMENT/templates/CMCB_TEST_REQUEST.allowed.schema.json`. Applying it over the original template should be a separate approved change.

## Non-Goals Until Approval

- Terraform apply
- Cloud VM creation
- Admin or sudo installs
- Public firewall ingress
- Tailscale auth enrollment
- Codex/OpenAI login
- Syncthing device pairing
- Git clone from private repos
- Any credential operation
