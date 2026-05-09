# CMCB Cross-Device Roadmap Status

Generated: 2026-05-08

## Phase status

| Phase | Status | Notes |
| --- | --- | --- |
| Package inventory and planning | Done | Source package read, plans and generated templates created. |
| Desktop/local base node | Done | Desktop agent, Syncthing, Tailscale, and validation are live. |
| ChatGPT online handoff | Done, temporary | Public handoff tunnel is live for laptop onboarding and review. |
| V: central shared drive | Done | `V:\CMCB-Central\CMCB-Shared` is the central artifacts/logs/test-packet root. |
| Laptop test node | Done, running | Laptop agent is running against `V:\CMCB-Central\CMCB-Shared`; smoke test `test_88fd27fe96` returned PASS. |
| Local aVM worker | Done | WSL2 Ubuntu 24.04 is bootstrapped, validated, and enrolled in Tailscale as `cmcb-local-avm` / `100.95.38.105`. |
| Cloud VM worker | Live on Oracle Always Free | Oracle VM is provisioned, bootstrapped, and enrolled in Tailscale as `cmcb-oracle-free-worker` / `100.98.49.26`. |
| iPhone/iPad control | Ready for review | iDevice plan and mobile handoff page are generated. |
| End-to-end cross-device validation | In progress | Core worker nodes are live; desktop and laptop file inventory smoke tests now PASS; Oracle repo refresh PASS; Oracle workspace inventory PASS; mirrored platform subtree inventories PASS; Oracle clone is clean after report cleanup; Oracle Terraform validate PASS; paired storage smoke now PASS; final job-routing coverage remains. |

## Active services

- Desktop local test agent: running.
- Syncthing: running.
- Tailscale desktop enrollment: running.
- ChatGPT handoff relay: running.
- Cloudflare handoff tunnel: running.
- Laptop watcher: running.
- WSL/Ubuntu local aVM: running and tailnet enrolled.
- Oracle VM: running and tailnet enrolled.
- Central shared root: `V:\CMCB-Central\CMCB-Shared`.
- Laptop agent: running against `V:\CMCB-Central\CMCB-Shared`.

## Next moves

1. If you want mirrored storage on a second machine, pair that machine to `V:\CMCB-Central\CMCB-Shared` with Syncthing or rclone.
2. Open `idevice_control.html` from an iPhone/iPad for mobile review.
3. Use the local aVM or Oracle VM for free worker tasks; both are now live.
4. Give the Oracle worker concrete repo jobs, then collect the results in `V:\CMCB-Central\CMCB-Shared`.
5. Desktop and laptop can now process `file_inventory` packets against the central shared root.
6. Next useful smoke step: run a build/test packet on the Oracle worker or mirror a richer artifact set.
7. Stop the public tunnel when onboarding is complete.

## Operator commands

Laptop onboarding:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
$u = "https://salvation-securities-makes-steps.trycloudflare.com/laptop_onboarding.ps1"
$p = "$env:TEMP\laptop_onboarding.ps1"
Invoke-WebRequest -UseBasicParsing $u -OutFile $p
powershell -ExecutionPolicy Bypass -File $p
```

Local aVM readiness check:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1
```

Local aVM WSL install approval:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1 -AllowAdminInstall
```

Stop public handoff:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\stop_chatgpt_handoff.ps1 -LogsDir .\shared\CMCB-Shared\logs
```
