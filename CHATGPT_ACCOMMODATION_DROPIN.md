# ChatGPT Drop-In: CMCB Accommodation Update

Use this note as a compact handoff for another ChatGPT session.

## What Was Done

- Refined `README_CODEX_CHATGPT_AGENT_ACCOMMODATION.md` so it behaves like a contract instead of a live status dump.
- Moved runtime state out of the README and into the live status surfaces.
- Kept the role split intact:
  - Codex implements scoped changes.
  - ChatGPT coordinates, reviews, and packages tasks.
  - The housekeeping agent handles approval-gated file operations.

## What Changed In The README

The README now:

- says it is the contract
- points to live state instead of duplicating it
- uses a source-of-truth order
- keeps live IPs, node readiness, and runtime details out of the static policy text
- keeps the public handoff as a read-only orientation surface

## Current Source Of Truth Order

1. `shared/CMCB-Shared/handoffs/chatgpt-online/status.json`
2. `shared/CMCB-Shared/handoffs/chatgpt-online/index.html`
3. `CONTROL_PLANE_STATUS.md`
4. `ROADMAP_STATUS.md`
5. `OPERATOR_NEXT_STEPS.md`
6. `MONITORING_AND_ESCALATION.md`
7. `CHATGPT_PROMPT_BUNDLE.md`
8. `HOUSEKEEPING_CONSOLE.md`

## Important Follow Rules

- Do not hard-code live IPs or node readiness into the README.
- Keep secrets, private keys, tokens, and `.env` files out of the public surface.
- Use the housekeeping flow for approval-gated file work.
- Use the public handoff only for sanitized orientation and check-in.

## Where Live State Lives

- Public handoff page: `https://salvation-securities-makes-steps.trycloudflare.com/`
- Latest check-in endpoint: `https://salvation-securities-makes-steps.trycloudflare.com/api/latest-checkin`
- Control plane status: `CONTROL_PLANE_STATUS.md`
- Handoff status: `shared/CMCB-Shared/handoffs/chatgpt-online/status.json`

## Why This Matters

This keeps the contract stable while letting the runtime evolve. If the environment changes, update the live status files first instead of rewriting the policy text.

## Fast Summary For Another ChatGPT

The accommodation README is now a contract file, not a live dashboard. The live handoff and status docs are the source of truth. Treat the housekeeping agent as the approval-gated file layer, and use the public handoff only as a sanitized read-only surface.
