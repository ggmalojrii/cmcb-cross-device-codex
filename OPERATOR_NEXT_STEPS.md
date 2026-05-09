# Operator Next Steps

Generated: 2026-05-08

## Current Local State

- Desktop local test agent: running
- Desktop local test agent PID file: `shared/CMCB-Shared/logs/desktop_agent.pid`
- Syncthing: running
- Syncthing PID file: `V:\CMCB-Central\CMCB-Shared\logs\syncthing.pid`
- Syncthing UI: `http://127.0.0.1:8384`
- Syncthing device ID: `V2UJEQX-DEY5REV-R3TZPKI-CIGRMCE-35CCXCA-OXX5RUT-3W3FKFG-FMS5TQK`
- Tailscale: logged in and running
- Tailscale hostname: `m-1232.tail62c74a.ts.net`
- Tailscale IPv4: `100.86.254.125`
- Tailnet: `ggmalojrii.github`
- CMCB shared folder: `V:\CMCB-Central\CMCB-Shared`
- SSH public key for future VM: `19_GENERATED_DEPLOYMENT/ssh/cmcb_codex_vm_ed25519.pub`
- SSH private key location: `~/.ssh/cmcb_codex_vm_ed25519`
- ChatGPT public handoff URL: `https://salvation-securities-makes-steps.trycloudflare.com`
- ChatGPT public status JSON: `https://salvation-securities-makes-steps.trycloudflare.com/status.json`
- Public laptop bootstrap ZIP: `https://salvation-securities-makes-steps.trycloudflare.com/laptop_node_bootstrap.zip`
- Laptop bootstrap ZIP SHA256: `dd3177d19b1bb7eed3f69bd451d3fee88b45531a694fa9e9d283503280731b59`
- Public laptop onboarding script: `https://salvation-securities-makes-steps.trycloudflare.com/laptop_onboarding.ps1`
- Laptop agent latest result: `test_v_central_laptop_agent` PASS
- Local aVM plan: `LOCAL_AVM_DEPLOYMENT_PLAN.md`
- Local aVM setup wrapper: `19_GENERATED_DEPLOYMENT/scripts/setup_local_avm_wsl.ps1`
- Oracle VM public IPv4: `192.9.157.198`
- Oracle VM private IPv4: `10.0.0.59`
- Oracle VM Tailscale IPv4: `100.98.49.26`
- Oracle VM Tailscale hostname: `cmcb-oracle-free-worker`
- Oracle VM SSH helper: `19_GENERATED_DEPLOYMENT/scripts/connect_oracle_vm.ps1`

## What To Do Now

1. Share the ChatGPT public handoff URL only when you want external review.
2. Stop the public tunnel when review is done.
3. Confirm this desktop appears in your Tailscale admin console.
4. Leave Syncthing open if you want mirrored storage, otherwise the laptop agent can keep running from `V:\CMCB-Central\CMCB-Shared`.
5. Use the local aVM or Oracle VM for free worker tasks.
6. When the VM or aVM exists, add its Syncthing device ID to this desktop and share only `CMCB-Shared`.
7. Keep laptop agent traffic pointed at `V:\CMCB-Central\CMCB-Shared`.
9. Do not sync secrets, `.env` files, SSH private keys, cloud tokens, browser cookies, or password databases.
10. If you want the Oracle worker to do real source work, provide or place the repo URL under `Git repo URL(s)` and use the SSH helper to reach the VM quickly.

## Stop Commands

Stop desktop local test agent:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\stop_local_test_agent.ps1 -PidFile V:\CMCB-Central\CMCB-Shared\logs\desktop_agent.pid
```

Stop Syncthing:

```powershell
$pid = Get-Content V:\CMCB-Central\CMCB-Shared\logs\syncthing.pid
Stop-Process -Id $pid
```

Stop public ChatGPT handoff tunnel and local handoff server:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\stop_chatgpt_handoff.ps1 -LogsDir V:\CMCB-Central\CMCB-Shared\logs
```

## Restart Commands

Restart desktop local test agent:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\run_local_test_agent.ps1 -NodeId desktop -SharedRoot V:\CMCB-Central\CMCB-Shared
```

Restart Syncthing:

```powershell
$UserPath = [Environment]::GetEnvironmentVariable('Path','User')
$MachinePath = [Environment]::GetEnvironmentVariable('Path','Machine')
$ProcessPath = [Environment]::GetEnvironmentVariable('Path','Process')
$env:Path = @($UserPath,$MachinePath,$ProcessPath) -join ';'
syncthing serve --home $env:USERPROFILE --no-browser --no-restart --gui-address http://127.0.0.1:8384
```

Check Tailscale:

```powershell
tailscale status
tailscale ip -4
```

Check public handoff:

```powershell
Invoke-WebRequest -UseBasicParsing https://salvation-securities-makes-steps.trycloudflare.com/status.json
```

Run laptop onboarding from the laptop:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
$u = "https://salvation-securities-makes-steps.trycloudflare.com/laptop_onboarding.ps1"
$p = "$env:TEMP\laptop_onboarding.ps1"
Invoke-WebRequest -UseBasicParsing $u -OutFile $p
powershell -ExecutionPolicy Bypass -File $p
```

Watch latest laptop check-in from this desktop:

```powershell
Invoke-WebRequest -UseBasicParsing https://salvation-securities-makes-steps.trycloudflare.com/api/latest-checkin
```

Check local aVM readiness without admin changes:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1
```

Install WSL/Ubuntu for the free local aVM after approval:

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\setup_local_avm_wsl.ps1 -AllowAdminInstall
```

## Remaining Cloud Inputs

- Oracle tenancy OCID
- Oracle user OCID
- Oracle fingerprint
- Oracle private key path
- Oracle compartment OCID
- Oracle region
- Oracle Ubuntu 24.04 image OCID
- SSH public key
- Terraform plan approval
- Terraform apply approval
- Tailscale enrollment strategy for the VM
