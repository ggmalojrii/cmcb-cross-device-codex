# ChatGPT Check-In Procedure

Generated: 2026-05-09

This is the procedure ChatGPT should follow before deciding whether to do more work or bring a problem back to you.

## Check-In Order

1. Read `shared/CMCB-Shared/handoffs/chatgpt-online/status.json`.
2. Read `shared/CMCB-Shared/handoffs/chatgpt-online/index.html`.
3. Read `ROADMAP_STATUS.md`.
4. Read `OPERATOR_NEXT_STEPS.md`.
5. Read `MONITORING_AND_ESCALATION.md` if any signal looks off.
6. Read `CHATGPT_PROMPT_BUNDLE.md` if you need to package the state into a prompt/zip for another model.
7. Read `HOUSEKEEPING_CONSOLE.md` if you need to request or review file-management work.

## Decision Rule

- If the live state matches the roadmap and the latest workers are passing, keep the machines moving and avoid bothering you.
- If a watch signal fires, stop the automated path for that node and tell you exactly what changed.
- If something needs approval, cost, secrets, or admin installs, stop and ask you before continuing.

## What ChatGPT Reports Back

- What is live right now.
- What the workers are doing.
- What passed recently.
- What failed or drifted, if anything.
- Whether you need to do anything or whether the machines can keep going.
- If a prompt/zip bundle is needed, include the current live state plus the exact files from `CHATGPT_PROMPT_BUNDLE.md`.
- If file work is needed, stage it as a housekeeping request packet and keep destructive work approval-gated.

## How This Saves Limits

- Routine checks stay local.
- ChatGPT is only used when the check-in sees a failure, a mismatch, or a new approval boundary.
- The handoff site is the shared reference point instead of a long chat loop.
