# Admin Privilege Install Protocol

## Purpose

Allow Codex/local scripts to request and perform approved software installs with admin privileges while preserving safety and auditability.

## Core rule

Codex may not silently elevate, bypass UAC/sudo, install unknown apps, or store credentials.

Admin installs require:

1. Explicit manifest entry.
2. `allow_admin_actions=true`.
3. `enabled=true` on the specific installer/package.
4. Official/approved source.
5. Checksum verification when available.
6. User approval of UAC/sudo prompt.
7. Install log.
8. Post-install validation.
9. Result packet.

## Windows

Use:
- winget when possible
- official installers only when manifest includes URL/checksum
- PowerShell `Start-Process -Verb RunAs` for UAC approval
- no credential capture
- stop if publisher is unknown or reboot is required

## Linux/cloud VM

Use:
- apt/dnf/brew/package managers where possible
- sudo only with user-approved terminal
- stop if credentials are required and user is unavailable
- log stdout/stderr
- validate installed command versions

## Stop conditions

- unknown publisher
- checksum mismatch
- missing checksum when not explicitly allowed
- credential prompt
- reboot required
- destructive file change
- installer wants browser/login approval
- unexpected EULA/prompt
- failed post-install validation

## Result location

```text
shared/CMCB-Shared/admin_install_results/
reports/
```
