# AGENTS.md — CMCB v18.27 Cross-Device VM Codex Environment

## Role

Use this package to set up a cloud VM Codex worker and optional desktop/laptop local test nodes.

## Source-of-truth hierarchy

1. User's current instruction
2. This AGENTS.md
3. CMCB v18.26 sync package/drop-in
4. NODE_REGISTRY.json
5. test request/result packets
6. admin install manifest
7. project files and logs
8. Central Chat relay packets

## Device roles

- VM_ORCHESTRATOR: cloud VM with Codex, builds, server tests, packaging, artifact sync.
- DESKTOP_TEST_NODE: desktop-local tests, Minecraft client tests, GPU/client visual checks, Windows-specific tools.
- LAPTOP_TEST_NODE: laptop-local tests, secondary client/launcher checks.
- IDEVICE_CONTROL: mobile SSH/dashboard/review only.
- CHATGPT_CENTRAL: command center/review/router.
- USER_MARTIN: approval and final authority.

## Local test rule

The VM must not assume it can directly control desktop/laptop. It sends explicit test request packets.

Desktop/laptop local test agents:
- run only when explicitly started
- execute allowlisted test types
- preserve originals
- log outputs
- return TEST_RESULT_PACKETs
- stop on unsafe/risky/credential/admin prompts

## Admin install rule

Codex/local scripts may install programs/apps with admin privileges only through explicit, reviewed manifests.

Required:
- `allow_admin_actions=true`
- installer/package explicitly enabled
- source is official/approved
- checksum required unless explicitly waived
- UAC/sudo prompt must be user-approved
- logs and validation required
- stop on unknown publisher, credentials, reboot requirement, destructive change, or ambiguous prompt

Do not bypass UAC/sudo or store credentials in files/logs/packets.

## Network rule

Use private networking. Prefer Tailscale. Do not expose SSH, SMB, dashboards, Minecraft test servers, or local test agents publicly unless explicitly configured.

## File sharing

Use:
- Git for source
- Syncthing/rclone/shared folder for artifacts/logs
- CMCB sync packets for Codex↔ChatGPT state
- test request/result packets for VM↔desktop/laptop testing

## Security

No secrets in packets/logs. API keys remain environment variables. Downloads are quarantined before use. No destructive deletes. No silent overwrites.

## Reporting

Use:

RESULT:
VM:
DESKTOP:
LAPTOP:
IDEVICES:
ADMIN_INSTALLS:
SYNC:
TESTS:
VALIDATION:
BLOCKED ONLY BY:
