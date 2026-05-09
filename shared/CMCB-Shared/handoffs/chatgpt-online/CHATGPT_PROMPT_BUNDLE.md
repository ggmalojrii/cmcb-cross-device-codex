# ChatGPT Prompt Bundle Spec

Generated: 2026-05-09

This file tells a future ChatGPT how to package the CMCB handoff into a prompt/zip bundle for review.

## Goal

Create a small bundle that lets ChatGPT inspect the current state, understand the live workers, and decide whether to continue locally or alert the user.

## Bundle Contents

Include these files in the zip:

1. `shared/CMCB-Shared/handoffs/chatgpt-online/status.json`
2. `shared/CMCB-Shared/handoffs/chatgpt-online/index.html`
3. `CHATGPT_CHECKIN_PROCEDURE.md`
4. `MONITORING_AND_ESCALATION.md`
5. `ROADMAP_STATUS.md`
6. `OPERATOR_NEXT_STEPS.md`
7. `VALIDATION_REPORT.md`
8. `GENERATED_FILES_MANIFEST.json`
9. `NODE_REGISTRY.json`
10. `README.md`

If the bundle is for the public handoff only, include the first four files plus the roadmap pair.
If the bundle is for a deeper review, include all ten.

## Prompt Template

Use a short prompt like this:

> Read the attached CMCB handoff bundle and tell me:
> 1. what is live now,
> 2. what is being worked on,
> 3. what passes or fails recently,
> 4. whether I need to do anything, and
> 5. what should happen next.
>
> If everything matches and the workers are passing, keep automation local and avoid paging me.
> If a watch signal fires, stop that automation and tell me exactly what changed.
> If anything needs approval, cost, secrets, or admin installs, stop and ask before continuing.

## What ChatGPT Should Check

1. `status.json` first.
2. `index.html` second.
3. `ROADMAP_STATUS.md` and `OPERATOR_NEXT_STEPS.md` for current direction.
4. `MONITORING_AND_ESCALATION.md` for tripwires.
5. `VALIDATION_REPORT.md` and `GENERATED_FILES_MANIFEST.json` if a deeper review is needed.
6. `NODE_REGISTRY.json` if there is any question about live node roles.

## What The Bundle Should Produce

The response should say:

- current live state
- current work in progress
- last known passes and failures
- any drift, risk, or approval boundary
- whether the user needs to act or the machines can keep going

## Packaging Rules

- Do not include secrets, private keys, cloud tokens, or password files.
- Keep paths relative inside the zip.
- Keep the bundle small and current.
- If the live state changes, regenerate the zip before asking ChatGPT to review it.

## If Something Is Off

If the bundle shows a mismatch, update the handoff files first, then rebuild the zip, then ask ChatGPT again.
