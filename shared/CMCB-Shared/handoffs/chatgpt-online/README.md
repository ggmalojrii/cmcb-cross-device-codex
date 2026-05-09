# CMCB ChatGPT Online Handoff

This folder is the sanitized public handoff surface for the current CMCB operating state.

It is sanitized:

- No credentials
- No private keys
- No cloud tokens
- No `.env` files
- No filesystem browsing outside this folder

Use `index.html` for human review and `status.json` for machine-readable status. The page now tracks the live operating phase, not just the setup phase.

For laptop setup, download `laptop_onboarding.ps1` and run it in PowerShell if you need to reinstall or recheck onboarding.

For safe file-management work, open `housekeeping.html` and build a request packet instead of using a raw terminal.
