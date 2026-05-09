# V Drive Centralization Report

Generated: 2026-05-08

## Result

PASS. `V:` is now the central drive for the CMCB shared artifacts/logs/test packets.

## Central Paths

- Central root: `V:\CMCB-Central`
- Central shared root: `V:\CMCB-Central\CMCB-Shared`
- Public handoff root: `V:\CMCB-Central\CMCB-Shared\handoffs\chatgpt-online`
- Logs root: `V:\CMCB-Central\CMCB-Shared\logs`

## Services Repointed

- Desktop local test agent: restarted against `V:\CMCB-Central\CMCB-Shared`.
- ChatGPT handoff server: restarted against `V:\CMCB-Central\CMCB-Shared\handoffs\chatgpt-online`.
- Laptop watcher: restarted against `V:\CMCB-Central\CMCB-Shared`.
- Syncthing folder `cmcb-shared`: config path updated to `V:\CMCB-Central\CMCB-Shared`.
- Local aVM: `/home/omnico/cmcb-work/shared/CMCB-Shared` now points to `/mnt/v/CMCB-Central/CMCB-Shared`.

## Validation

- Initial and final copies to `V:` completed with Robocopy success exit codes.
- Desktop packet probe `test_v_central_probe` returned PASS from `V:\CMCB-Central\CMCB-Shared`.
- Public handoff `status.json` returns the V: central shared root.
- Local aVM can see the V: central probe packet through `/mnt/v/CMCB-Central/CMCB-Shared`.
- Laptop watcher is running against the V: root.
- Laptop agent `test_v_central_laptop_agent` returned PASS from `V:\CMCB-Central\CMCB-Shared`.

## Compatibility

Generated PowerShell scripts now support `CMCB_SHARED_ROOT`. The user-level environment variable is set to:

```text
V:\CMCB-Central\CMCB-Shared
```

An attempted package-folder junction was not completed because Windows denied moving Syncthing's hidden `.stfolder`. The old package-local shared folder was left intact as a fallback. A partial backup folder named `shared\CMCB-Shared.pre-v-central-*` may exist from that attempt. Live services use `V:` directly.

## Safety

- No cloud resources created.
- No public ports changed.
- No secrets written.
- No destructive delete performed.
