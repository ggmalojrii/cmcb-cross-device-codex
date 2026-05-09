# Operator Next Steps

Generated: 2026-05-09

## Right Now

We are no longer in setup mode. The live state is:

- Desktop test node: running
- Laptop test node: running against `V:\CMCB-Central\CMCB-Shared`
- Local aVM: running and tailnet-enrolled
- Oracle Always Free VM: running and tailnet-enrolled
- Central shared root: `V:\CMCB-Central\CMCB-Shared`

## What We Are Working On

1. Keeping the public handoff aligned with the live state.
2. Using the Oracle worker for real repo jobs, not just health checks.
3. Keeping the desktop and laptop pointed at the shared root.
4. Keeping the local aVM available as the free fallback worker.
5. Keeping the Oracle mirror healthy and free.
6. Surfacing failure signals clearly so you only step in when something actually needs attention.
7. Using the housekeeping console to stage file changes safely instead of opening a raw terminal on the public site.
8. Reading the control plane plan and status before any Cockpit or Tailscale SSH work.
9. Noting that the Oracle accommodation drift audit already passed.
10. Noting that the Oracle repo validation after the accommodation updates also passed.
11. Using the Oracle worker for a richer repo task next instead of re-running the same audit.

## What Happens Next

1. Run a focused repo task on the Oracle worker.
2. Keep the laptop and desktop smoke checks pointed at `V:\CMCB-Central\CMCB-Shared`.
3. Refresh the public handoff if the live state changes.
4. Stop the public tunnel when nobody needs external review.
5. The latest Oracle batch (`repo_status5` + `workspace_inventory8`) already passed, so the next batch can target a richer repo task.
6. Stage a housekeeping request packet if you want the agent to fix or tidy files for you.
7. Read `LIVE_CONTROL_PLANE_PLAN.md` and `CONTROL_PLANE_STATUS.md` for the browser panel and tailnet SSH endpoints.
8. Keep `MONITORING_AND_ESCALATION.md` handy for the signals that should interrupt the normal loop.
9. Keep the accommodation contract stable unless the live surface changes again.
10. Use the Oracle worker for the next repo task instead of another drift pass.
11. Keep the result path available for the repo validation run: `V:\CMCB-Central\CMCB-Shared\test_results\cloud_vm\test_cloud_vm_contract_validate1.json`.

## Live Endpoints and Paths

- Public handoff URL: `https://salvation-securities-makes-steps.trycloudflare.com`
- Public status JSON: `https://salvation-securities-makes-steps.trycloudflare.com/status.json`
- Public housekeeping console: `https://salvation-securities-makes-steps.trycloudflare.com/housekeeping.html`
- Live control plane plan: `https://salvation-securities-makes-steps.trycloudflare.com/LIVE_CONTROL_PLANE_PLAN.md`
- Control plane status: `https://salvation-securities-makes-steps.trycloudflare.com/CONTROL_PLANE_STATUS.md`
- Laptop onboarding script: `https://salvation-securities-makes-steps.trycloudflare.com/laptop_onboarding.ps1`
- Laptop bootstrap ZIP: `https://salvation-securities-makes-steps.trycloudflare.com/laptop_node_bootstrap.zip`
- Desktop local test agent PID file: `shared/CMCB-Shared/logs/desktop_agent.pid`
- Syncthing UI: `http://127.0.0.1:8384`
- Central shared folder: `V:\CMCB-Central\CMCB-Shared`
- Oracle VM SSH helper: `19_GENERATED_DEPLOYMENT/scripts/connect_oracle_vm.ps1`
- Oracle VM clone: `~/cmcb-work/projects/cmcb-cross-device-codex`

## Safety Boundaries

- Do not sync secrets, private keys, browser cookies, cloud tokens, password databases, or `.env` files into the shared root.
- Keep the Oracle VM on the free-tier path unless you explicitly choose to spend money.
- Keep the public handoff sanitized; it is for status, not secrets.
- Keep housekeeping requests inside the approved roots and approval gates.
- Keep the control plane on Tailscale/private access only.

## Useful Commands

### Refresh desktop agent

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\run_local_test_agent.ps1 -NodeId desktop -SharedRoot V:\CMCB-Central\CMCB-Shared
```

### Check public handoff

```powershell
Invoke-WebRequest -UseBasicParsing https://salvation-securities-makes-steps.trycloudflare.com/status.json
```

### Open the Oracle worker

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\connect_oracle_vm.ps1
```

### Stop the public tunnel

```powershell
powershell -ExecutionPolicy Bypass -File .\19_GENERATED_DEPLOYMENT\scripts\stop_chatgpt_handoff.ps1 -LogsDir V:\CMCB-Central\CMCB-Shared\logs
```
