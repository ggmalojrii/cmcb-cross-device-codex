# CMCB Housekeeping Console

Generated: 2026-05-09

This is the request/approval surface for routine file maintenance inside CMCB.

## Purpose

Use this console to stage safe file-management work for the CMCB repo and the live handoff surface without opening a raw terminal to the public page.

The console is meant for:

- adding files
- editing files
- deleting files
- moving or renaming files
- listing or inspecting files before a change

It is not meant for:

- secrets
- private keys
- cloud tokens
- `.env` files
- arbitrary shell commands
- anything outside the allowed CMCB roots

## Allowed Roots

The housekeeping workflow is limited to these roots:

1. `repo_clone`
2. `shared/CMCB-Shared/handoffs/chatgpt-online`

If a request points elsewhere, it should be blocked and brought back for review.

## Approval Rule

- Non-destructive requests can be staged.
- Destructive requests require explicit approval before the agent applies them.
- The agent should never act on a request that escapes the allowed roots.

## Request Format

Housekeeping requests are JSON packets with the `CMCB_HOUSEKEEPING_REQUEST` packet type.

The request should say:

- what root to use
- what operation to perform
- which relative path to touch
- the replacement content, if needed
- the destination path for a move or rename, if needed
- whether the request is a dry run
- whether the user has approved a destructive action

## Queue Flow

1. Use the live Housekeeping Console page to build or download a request packet.
2. Save the request packet into the pending queue if you want it reviewed.
3. Move approved packets into the approved queue.
4. Let the housekeeping agent process the approved queue.
5. Read the result packet and logs in the shared housekeeping folder.

## Result Flow

Every applied request should leave behind:

- a result JSON packet
- a log note or file listing when useful
- a backup copy for any edited or deleted file when practical

## Safe Rule

If the request touches a path that looks like a secret, a key, or a credential store, stop and bring it back for review.
