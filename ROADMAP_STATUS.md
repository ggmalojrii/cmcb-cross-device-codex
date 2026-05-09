# CMCB Cross-Device Roadmap Status

Generated: 2026-05-09

## Where We Are

The CMCB environment is now in the operating phase, not the setup phase.

Live today:
- Desktop test node is running.
- Laptop test node is running against `V:\CMCB-Central\CMCB-Shared`.
- Local aVM is running on WSL2 Ubuntu 24.04 and is tailnet-enrolled.
- Oracle Always Free VM is running and is tailnet-enrolled.
- `V:\CMCB-Central\CMCB-Shared` is the central shared root for artifacts, logs, and test packets.

Still intentional:
- Cloud VM is being used as the Oracle Always Free mirror, not a paid cloud worker.
- iPhone/iPad access is review/control only.

## Timeline

| Stage | Status | What happened |
| --- | --- | --- |
| 1. Inventory and planning | Done | Read the setup package, created the generated plans, templates, and validation material. |
| 2. Desktop base node | Done | Desktop agent, Syncthing, and Tailscale came online first. |
| 3. Shared root move | Done | `V:\CMCB-Central\CMCB-Shared` became the central drive for live artifacts. |
| 4. Laptop onboarding | Done | Laptop agent is live and checking in against the shared root. |
| 5. Local aVM | Done | WSL2 Ubuntu 24.04 came online as a free local worker. |
| 6. Oracle Always Free mirror | Done | Oracle VM was provisioned, bootstrapped, and validated. |
| 7. Worker packets | Done | Repo refresh, workspace inventory, subtree inventory, Terraform validate, and Terraform fmt-check all passed on Oracle. |
| 8. Current operating loop | In progress | We are now using the live workers for real repo and smoke-check tasks, not just setup. |

## What Has Been Verified

- Desktop `file_inventory` and `artifact_presence` packets pass.
- Laptop `file_inventory` and `artifact_presence` packets pass.
- Oracle `repo_refresh`, `repo_status`, `repo_validate`, `workspace_inventory`, `terraform_validate`, `terraform_fmt_check`, `git_log`, and subtree inventory packets pass.
- Latest Oracle live batch also passed:
  - `test_cloud_vm_repo_status5`
  - `test_cloud_vm_workspace_inventory8`
- Packet schema drift was resolved.
- Generated report cleanup left the Oracle clone clean after validation.

## What We Are Working On Now

1. Keep the public handoff aligned with the live state.
2. Use the Oracle worker for real repo jobs instead of only health checks.
3. Keep the laptop and desktop pointed at `V:\CMCB-Central\CMCB-Shared`.
4. Keep the local aVM available as the free fallback worker.
5. Keep the Oracle Always Free mirror healthy without introducing paid cloud usage.
6. Use the housekeeping console for request-driven file edits instead of raw terminal work on the public page.
7. Use the Cockpit-based control plane on the Oracle VM and local aVM.

## What Is Next

1. Run a focused repo task on the Oracle worker.
2. Add mirrored storage on any additional machine that should participate in the shared root.
3. Open the iDevice control page for review-only access if needed.
4. Stage the first housekeeping request packet if you want the agent to fix docs or files for you.
5. Read `LIVE_CONTROL_PLANE_PLAN.md` and `CONTROL_PLANE_STATUS.md` for control-plane usage details.
6. Stop the public tunnel once it is no longer needed for onboarding or review.
7. Use `MONITORING_AND_ESCALATION.md` as the quick list for what should interrupt the normal loop.

## Operator Commands

### Refresh the Oracle worker from Windows

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\connect_oracle_vm.ps1
```

### Laptop onboarding

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
$u = "https://salvation-securities-makes-steps.trycloudflare.com/laptop_onboarding.ps1"
$p = "$env:TEMP\laptop_onboarding.ps1"
Invoke-WebRequest -UseBasicParsing $u -OutFile $p
powershell -ExecutionPolicy Bypass -File $p
```

### Stop the public handoff

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\stop_chatgpt_handoff.ps1 -LogsDir V:\CMCB-Central\CMCB-Shared\logs
```
