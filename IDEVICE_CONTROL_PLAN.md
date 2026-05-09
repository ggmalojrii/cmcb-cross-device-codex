# iPhone/iPad Control Plan

Generated: 2026-05-08

## Role

iPhone and iPad devices are review/control clients only. They should not hold cloud provider credentials, SSH private keys, OpenAI keys, or shared folders containing secrets.

## Target access

- Primary network: Tailscale private tailnet.
- Public access: temporary sanitized handoff page only.
- SSH: private tailnet only, once the VM or local aVM has SSH configured.
- Review: status pages, reports, logs, generated manifests, and approval prompts.

## Current access options

1. Temporary public handoff:

   ```text
   https://salvation-securities-makes-steps.trycloudflare.com
   ```

   Use this only for sanitized status and onboarding links. Stop the tunnel when finished.

2. Tailscale control path:

   - Install Tailscale from the iOS App Store.
   - Log into the same tailnet as the desktop.
   - Confirm this desktop appears as `m-1232` / `100.86.254.125`.
   - Use private tailnet addresses for future dashboards or SSH targets.

3. SSH review path, after VM/aVM SSH is configured:

   - Use an iOS SSH client such as Termius, Blink Shell, Secure ShellFish, or Working Copy.
   - Connect only to Tailscale IP/DNS names.
   - Do not expose SSH publicly.
   - Store any mobile SSH key in the iOS secure keychain if one is needed.

## Mobile approval workflow

1. Review `ROADMAP_STATUS.md`, `VALIDATION_REPORT.md`, and `NEXT_APPROVAL_PROMPT.md`.
2. Approve only one risky class at a time:
   - WSL/admin install
   - Ubuntu apt installs
   - cloud credentials
   - Terraform apply
   - public ingress
3. Reply in chat with the exact approval target.
4. Codex performs that one approved step and writes a report.

## Do not put on iDevices

- Cloud provider tokens.
- Tailscale auth keys.
- OpenAI/Codex auth tokens.
- SSH private keys copied from the desktop.
- `.env` files.
- Syncthing folders containing artifacts unless explicitly needed.

## Success criteria

- iDevice can open the temporary public handoff page.
- iDevice can see the desktop in Tailscale.
- iDevice can review generated reports.
- Future VM/aVM SSH access uses Tailscale-only addresses.
