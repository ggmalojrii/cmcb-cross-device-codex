# START HERE — Cross-Device VM Codex Environment

## Goal

Create one cloud VM that Codex can use as the main worker, while desktop/laptop act as optional local test nodes.

## Device roles

```text
Cloud VM       = Codex orchestrator/build/server worker
Desktop        = local test node + control station
Laptop         = local test node + control station
iPhone/iPad    = mobile review/control clients
Central Chat   = CMCB command center
```

## Setup order

1. Create cloud VM.
2. Install Tailscale on VM, desktop, laptop, and iDevices.
3. Install Codex CLI and tools on the VM.
4. Set up Git for source code.
5. Set up Syncthing/rclone/shared folder for logs/artifacts.
6. Extract CMCB v18.26 Codex drop-in into VM projects.
7. Install local test node package on desktop/laptop.
8. Start local test agents only when you want tests to run.
9. Use CMCB test request/result packets for VM↔desktop/laptop testing.
10. Use admin-install manifests only when you want Codex/local scripts to request elevated installs.

## VM first command

```bash
bash 13_SCRIPTS/bootstrap_cloud_vm.sh
```

## Windows desktop/laptop first command

Run PowerShell:

```powershell
powershell -ExecutionPolicy Bypass -File .\13_SCRIPTS\bootstrap_windows_test_node.ps1
```

## Start local test agent

```bash
python 13_SCRIPTS/local_test_agent.py --node-id desktop --shared-root ./shared/CMCB-Shared
```

or on laptop:

```bash
python 13_SCRIPTS/local_test_agent.py --node-id laptop --shared-root ./shared/CMCB-Shared
```

## VM creates test request

```bash
python 13_SCRIPTS/vm_orchestrator.py create-test --target desktop --test-type file_inventory --artifact shared/CMCB-Shared/artifacts/example.txt
```

## VM collects results

```bash
python 13_SCRIPTS/vm_orchestrator.py collect-results --shared-root ./shared/CMCB-Shared
```

## Admin-install planning

```bash
python 13_SCRIPTS/admin_install_manager.py plan
```

## Admin-install execution

Only after editing `11_ADMIN_INSTALLS/ADMIN_INSTALL_MANIFEST.json` and setting `allow_admin_actions=true`:

Windows:
```powershell
powershell -ExecutionPolicy Bypass -File .\13_SCRIPTS\run_admin_install_windows.ps1
```

Linux:
```bash
python 13_SCRIPTS/admin_install_manager.py run-linux
```
