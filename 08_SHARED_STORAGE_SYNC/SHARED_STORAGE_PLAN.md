# Shared Storage / Sync Plan

## Use Git for source

Use Git for code, configs, scripts, AGENTS.md, and CMCB files.

## Use Syncthing/rclone/shared folders for artifacts/logs

Recommended shared folder:

```text
CMCB-Shared/
  test_requests/
    desktop/
    laptop/
  test_results/
    desktop/
    laptop/
  artifacts/
  logs/
  screenshots/
  handoffs/
  cmcb_sync/
  admin_install_requests/
  admin_install_results/
```

## Do not sync secrets

Do not place API keys, private keys, tokens, cookies, or passwords in shared folders.
