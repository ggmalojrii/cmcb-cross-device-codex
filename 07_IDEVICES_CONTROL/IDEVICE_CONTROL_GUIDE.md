# iPhone / iPad Control Guide

Use iDevices as control/review clients:

- install Tailscale
- use SSH app such as Blink Shell, Termius, or similar
- connect to the VM by Tailscale name/IP
- use tmux to attach to Codex sessions
- review reports/logs through synced folders or web dashboard

Typical commands:

```bash
ssh <vm-user>@<tailscale-vm-name>
tmux attach -t codex
```

Do not use iDevices as heavy build/test workers.
