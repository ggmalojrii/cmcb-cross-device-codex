# Monitoring And Escalation

Generated: 2026-05-09

This is the short answer to: how do problems get your attention?

## Normal State

- Oracle runs routine repo checks.
- Desktop and laptop run local smoke checks.
- The local aVM stays available as the free fallback worker.
- The public handoff mirrors the live state for quick review.

## Bring It Back To Me If

1. Oracle worker packets fail, stall, or report a missing file or permission issue.
2. Desktop or laptop smoke checks stop reporting PASS.
3. Tailscale drops off on the Oracle VM, local aVM, desktop, or laptop.
4. The public handoff no longer matches the live state.
5. A change needs approval, cost, secrets, or admin installs.
6. A housekeeping request gets stuck in pending or approved without a result packet.

## First Place To Look

- `V:\CMCB-Central\CMCB-Shared\logs`
- `ROADMAP_STATUS.md`
- `OPERATOR_NEXT_STEPS.md`
- `shared/CMCB-Shared/handoffs/chatgpt-online/status.json`
- `shared/CMCB-Shared/handoffs/chatgpt-online/index.html`
- `shared/CMCB-Shared/handoffs/chatgpt-online/housekeeping.html`

## What I Do When Something Breaks

- Pause the affected automation.
- Capture the error in shared logs.
- Update the handoff so the issue is visible.
- Tell you exactly what needs your attention.
- Move or re-stage housekeeping packets when a request is blocked by path safety or approval gates.

## Your Rule Of Thumb

- If it is boring and repeatable, let the machines do it.
- If it is a failure signal or needs judgment, come back to me.
