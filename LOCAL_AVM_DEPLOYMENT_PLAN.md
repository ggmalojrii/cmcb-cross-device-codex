# Local aVM Deployment Plan

Generated: 2026-05-08

## Purpose

Implement the free/local aVM lane using WSL2 with Ubuntu 24.04 LTS. This gives the workstation a Linux VM-style Codex/build worker without creating paid cloud resources.

## Current status

- Desktop node: ready and running.
- Laptop node: onboarding package is ready; waiting for real laptop check-in.
- Cloud VM: planned only; no provider credentials or paid resources used.
- Local aVM: blocked until WSL is installed and initialized.

## Target design

- Host: Windows desktop/laptop.
- Local VM layer: WSL2.
- Guest OS: Ubuntu 24.04 LTS.
- Worker role: VM_ORCHESTRATOR_LOCAL_AVM.
- Network: Tailscale/private access only when enabled.
- Public ports: closed by default.
- Source sync: Git.
- Artifact/log sync: shared CMCB folder, Syncthing, or rclone.
- Secrets: environment variables only; no secrets written into generated files.

## Approval gates

The generated WSL setup script is safe by default:

- It does not install WSL unless `-AllowAdminInstall` is explicitly passed.
- It does not run `apt-get install` unless `-AllowAptInstall` is explicitly passed.
- It does not enroll Tailscale unless `TAILSCALE_AUTH_KEY` exists in the environment.
- It does not install Codex inside Ubuntu unless `CMCB_APPROVE_CODEX_INSTALL=1` is set.

## Implementation steps

1. Run a dry/local readiness check:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1
   ```

2. If WSL is missing, approve the Windows UAC prompt and install Ubuntu 24.04:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1 -AllowAdminInstall
   ```

3. Reboot if Windows requires it.

4. Launch Ubuntu once from the Start menu or with:

   ```powershell
   wsl -d Ubuntu-24.04
   ```

   Complete the initial Linux username/password setup if prompted.

5. Bootstrap the aVM without package installs:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1
   ```

6. After approval, allow Ubuntu package installs:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1 -AllowAptInstall
   ```

## Success criteria

- `wsl -l -v` lists `Ubuntu-24.04`.
- `~/cmcb-work/shared/CMCB-Shared` exists inside Ubuntu.
- `~/cmcb-work/reports/ENVIRONMENT_VALIDATION_REPORT.json` exists inside Ubuntu.
- Validation report shows at least `git`, `python3`, `node`, `npm`, and `java` after approved installs.
- Tailscale is private-network only and is not exposed through public ports.

## Current block

WSL is not installed. The next operator action is to approve the WSL/Ubuntu install or choose a different local VM backend.
