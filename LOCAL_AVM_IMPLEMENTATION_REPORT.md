# Local aVM Implementation Report

Generated: 2026-05-08

## Result

PASS. The free/local aVM worker is implemented with WSL2 and Ubuntu 24.04.

## Node

- Node ID: `local_avm`
- Role: `VM_ORCHESTRATOR_LOCAL_AVM`
- Distro: `Ubuntu-24.04`
- Linux user: `omnico`
- Work root: `/home/omnico/cmcb-work`
- Shared root: `/home/omnico/cmcb-work/shared/CMCB-Shared`
- Shared root mapping: symlink to the package `shared/CMCB-Shared` folder on Windows
- Tailscale hostname: `cmcb-local-avm`
- Tailscale IPv4: `100.95.38.105`

## Installed Tooling

- Git: present
- Python 3: present
- Node/npm: present
- Java 21: present
- Gradle: present
- rclone: present
- Syncthing: present
- Tailscale: present and enrolled
- Codex CLI: native Linux install present

## Validation

- `wsl -l -v` reported `Ubuntu-24.04` running under WSL2.
- Ubuntu command execution works as user `omnico`.
- aVM environment validation report exists.
- Windows can ping `100.95.38.105` through Tailscale.
- aVM can see both itself and desktop `m-1232` in Tailscale status.
- Shared folder report is visible from both Ubuntu and Windows.

## Safety

- No cloud resources were created.
- No public SSH or VM ports were opened.
- No Tailscale auth key was written to disk.
- No OpenAI/Codex auth token was written to disk.
- The temporary public handoff remains limited to sanitized files.

## Remaining

- Laptop node still needs real onboarding and smoke-test completion.
- Cloud VM remains planned only.
- Codex authentication inside Ubuntu may still require interactive login before live Codex work.
