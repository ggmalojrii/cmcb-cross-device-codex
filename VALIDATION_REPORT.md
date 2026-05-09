# Validation Report

Generated: 2026-05-09
Package date: 2026-05-07

## Safety

- Terraform apply run: no
- Cloud resources created: no
- Admin installs run: no
- Public ports opened: no
- Secrets written: no
- Destructive edits: no

## Package Checks

- Extracted package inventory completed.
- SHA256 verification previously passed for extracted package contents.
- Existing package validation report says PASS.
- Existing generated package contains embedded CMCB v18.24, v18.25, and v18.26 artifacts.

## Generated File Checks

- JSON parse validation: PASS
- PowerShell parser validation for generated `.ps1` scripts: PASS
- Bash syntax validation for generated `.sh` scripts: PASS
- Cloud-init static checks: PASS
  - First line is `#cloud-config`
  - No tabs detected
  - Contains `packages`, `write_files`, and `runcmd`
  - No obvious Tailscale auth key literal detected
- Secret pattern scan for obvious key literals: PASS
- Updated local validation after installs: PASS
- Package `validate_environment.py`: PASS
- Desktop local test packet loop: PASS
  - Created `file_inventory` test request.
  - Ran desktop local test agent once.
  - Collected PASS result.
- Desktop background agent loop: PASS
  - Started background agent.
  - Created `artifact_presence` request.
  - Collected PASS result.
- SSH key preparation: PASS
  - Dedicated private key created under `~/.ssh`.
  - Public key copied into generated SSH folder.
- Tailscale desktop enrollment: PASS
  - Tailscale IPv4: `100.86.254.125`
  - Tailscale DNS name: `m-1232.tail62c74a.ts.net`
- Syncthing local/private configuration: PASS
  - `CMCB-Shared` folder added as `cmcb-shared`.
  - Global announce, relays, NAT traversal, browser auto-start, and crash reporting disabled.
  - Tailnet range `100.64.0.0/10` added as local.
- ChatGPT public handoff tunnel: PASS
  - Local handoff server: `http://127.0.0.1:8765`
  - Public URL: `https://salvation-securities-makes-steps.trycloudflare.com`
  - Public `status.json` returned HTTP 200.
  - Public surface is the sanitized operating handoff folder only.
  - Public handoff page now reflects the live operating phase and current roadmap snapshot.
- ChatGPT check-in procedure: PASS
  - `CHATGPT_CHECKIN_PROCEDURE.md` added as the decision order for checking the handoff.
  - `MONITORING_AND_ESCALATION.md` added as the interruption list.
- Housekeeping console: PASS
  - `HOUSEKEEPING_CONSOLE.md` added as the request/approval guide for safe file management.
  - `housekeeping.html` added as the live console for request packet generation.
  - `housekeeping_agent.py` added as the approval-gated queue processor for safe add/edit/delete work.
- Live control plane plan: PASS
  - `LIVE_CONTROL_PLANE_PLAN.md` added as the research-backed recommendation for Cockpit, Cockpit Files, and Tailscale SSH.
- Control plane deployment: PASS
  - Cockpit, Cockpit Files, Cockpit System, Cockpit NetworkManager, Cockpit Storaged, and Cockpit PackageKit installed on Oracle VM and local aVM.
  - `cockpit.socket` active and listening on `9090` on both nodes.
  - `tailscale up --ssh` executed on both nodes.
  - Tailnet access tested with `curl -k -I` against `https://100.98.49.26:9090` and `https://100.95.38.105:9090`.
- Laptop public onboarding: PASS
  - `laptop_onboarding.ps1` PowerShell parser validation passed.
  - Public onboarding script returned HTTP 200.
  - Laptop bootstrap ZIP public download hash matched expected SHA256.
- Laptop check-in relay: PASS
  - Public `/api/laptop-checkin` accepted a test check-in.
  - Public `/api/latest-checkin` returned the latest sanitized check-in.
- Laptop agent smoke test: `test_v_central_laptop_agent` PASS
- Local aVM WSL wrapper: PASS static generation and dry run
  - `setup_local_avm_wsl.ps1` added with explicit gates for WSL admin install and Ubuntu apt installs.
  - `LOCAL_AVM_DEPLOYMENT_PLAN.md` and `ROADMAP_STATUS.md` added.
  - Dry run wrote `reports/LOCAL_AVM_WSL_SETUP_REPORT.json` with expected `BLOCKED` status because WSL is not installed.
  - Forced WSL install path launched and `wsl -l -v` reported `Ubuntu-24.04` running.
  - Ubuntu first-run completed.
  - Toolchain installed and validated: Git, Python 3, Node/npm, Java 21, Gradle, rclone, Syncthing, Tailscale, and native Linux Codex CLI.
  - Shared root symlinked to the Windows package `shared/CMCB-Shared`.
  - Tailscale enrollment completed as `cmcb-local-avm` / `100.95.38.105`.
  - Windows Tailscale ping to `100.95.38.105`: PASS.
- iDevice control lane: PASS
  - `IDEVICE_CONTROL_PLAN.md` added.
  - Public sanitized `idevice_control.html` added.
- V: central shared drive: PASS
  - `V:\CMCB-Central\CMCB-Shared` created and populated.
  - Desktop local test agent, handoff server, laptop watcher, Syncthing config, and local aVM shared-root symlink were repointed to `V:`.
  - Package scripts now support `CMCB_SHARED_ROOT`.
  - User environment variable `CMCB_SHARED_ROOT` is set to `V:\CMCB-Central\CMCB-Shared`.
  - Desktop packet probe `test_v_central_probe`: PASS.
  - Public handoff `status.json` reports `V:\CMCB-Central\CMCB-Shared`: PASS.
  - Local aVM readback of V: central probe packet: PASS.
  - Desktop `file_inventory` smoke packet `test_v_central_desktop_file_inventory`: PASS.
  - Laptop `file_inventory` smoke packet `test_v_central_laptop_file_inventory`: PASS.
  - Desktop `artifact_presence` smoke packet `test_v_central_desktop_artifact_presence`: PASS.
  - Laptop `artifact_presence` smoke packet `test_v_central_laptop_artifact_presence`: PASS.
- Oracle VM worker: PASS
  - Oracle VM provisioned on Always Free path.
  - VM `cmcb-oracle-free-worker` enrolled in Tailscale with IPv4 `100.98.49.26`.
  - VM can ping the local aVM and desktop over tailnet.
  - VM user-service `syncthing` enabled and running.
  - Oracle VM bootstrap status packet copied into `V:\CMCB-Central\CMCB-Shared\logs\oracle_vm_bootstrap_status.json`.
  - Windows SSH helper `19_GENERATED_DEPLOYMENT/scripts/connect_oracle_vm.ps1` added for quick VM access.
  - Windows SSH helper PowerShell parse validation: PASS.
  - Oracle VM repo-native environment validation: PASS.
  - Oracle worker refresh scripts added: `sync_oracle_worker.sh` and `update_oracle_worker.ps1`.
  - Cloud VM packet lane PASS: `test_cloud_vm_repo_status` handled by `13_SCRIPTS/oracle_worker_agent.py`.
  - Oracle worker persistent service files added: `run_oracle_worker_agent.sh`, `install_oracle_worker_service.sh`, and `cmcb-oracle-worker.service`.
  - Cloud VM repo validation lane now allowlists `repo_validate` for compile-plus-validation packets.
  - Cloud VM packet transport now accepts UTF-8 and UTF-8 BOM JSON from Windows-created packets.
  - Windows SSH helper `connect_oracle_vm.ps1` now writes its local/shared reports with BOM-free UTF-8 encoding.
  - Cloud VM repo status on refreshed head `test_cloud_vm_repo_status2`: PASS.
  - Cloud VM repo refresh on refreshed head `test_cloud_vm_repo_refresh1`: PASS.
  - Cloud VM workspace inventory packet `test_cloud_vm_workspace_inventory1`: PASS.
  - Cloud VM focused subtree inventory `test_cloud_vm_subtree_inventory1`: PASS.
  - Cloud VM mirrored platform subtree inventory `test_cloud_vm_subtree_inventory2`: PASS.
  - Cloud VM repo status after report cleanup `test_cloud_vm_repo_status3`: PASS and clean.
  - Cloud VM Terraform validation packet `test_cloud_vm_terraform_validate1`: PASS.
  - Cloud VM Terraform validation packet `test_cloud_vm_terraform_validate2`: PASS using resolved `~/bin/terraform`.
  - Cloud VM Terraform fmt-check packet `test_cloud_vm_terraform_fmt_check1`: PASS.
  - `12_TEMPLATES/CMCB_TEST_REQUEST.schema.json` updated to match the live packet allowlist.
  - Cloud VM schema subtree inventory `test_cloud_vm_subtree_inventory5`: PASS.
  - Latest Oracle live batch:
    - `test_cloud_vm_repo_status5`: PASS
    - `test_cloud_vm_workspace_inventory8`: PASS
- Terraform after install:
  - `terraform fmt -check`: PASS
  - `terraform init -backend=false`: PASS
  - `terraform validate`: PASS
  - Oracle free-tier template initialized and validated with the local Terraform CLI.

## Warnings

- Syncthing is installed and locally configured, but not paired with VM/laptop.
- rclone is installed but no remote is configured.
- Paid cloud provider is not selected, so Terraform apply remains blocked for any paid path.
- Oracle Always Free template files were added, but no Oracle resources were created or applied.
- Public handoff tunnel remains sanitized and should be stopped when external review is done.
- Codex CLI is installed inside the local aVM, but live Codex work may require interactive Codex/OpenAI authentication.
- The old package-local `shared\CMCB-Shared` folder remains as fallback. Live services use `V:\CMCB-Central\CMCB-Shared` directly.
- A partial `shared\CMCB-Shared.pre-v-central-*` backup may exist from the attempted junction swap; it is not the live shared root.
- The Oracle Terraform template is still a template only; it needs real OCIDs and image selection before `terraform plan` on an actual account.
