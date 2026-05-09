# CMCB Control Plane Status

Generated: 2026-05-09

## Current State

The browser control plane is installed and reachable on the live Linux nodes.

### Oracle VM

- Hostname: `cmcb-oracle-free-worker`
- Tailnet IP: `100.98.49.26`
- Cockpit URL: `https://100.98.49.26:9090`
- Installed: Cockpit, Cockpit Files, Cockpit System, Cockpit NetworkManager, Cockpit Storaged, Cockpit PackageKit
- Service state: `cockpit.socket` active and listening on `9090`
- Tailnet SSH: enabled with `tailscale up --ssh`

### Local aVM

- Hostname: `cmcb-local-avm`
- Tailnet IP: `100.95.38.105`
- Cockpit URL: `https://100.95.38.105:9090`
- Installed: Cockpit, Cockpit Files, Cockpit System, Cockpit NetworkManager, Cockpit Storaged, Cockpit PackageKit
- Service state: `cockpit.socket` active and listening on `9090`
- Tailnet SSH: enabled with `tailscale up --ssh`

## Access Rules

- Use Tailscale to reach the panel.
- Keep the panel off the public internet.
- Keep file edits inside the housekeeping request flow for anything that should be approval-gated.

## What The Agent Can Do Here

- Open Cockpit in the browser.
- Use Cockpit terminal for shell work over the tailnet.
- Use Cockpit Files for browser file operations.
- Use Tailscale SSH for direct shell access when needed.

## What Comes Next

1. Sign in to Cockpit with a sudo-capable Linux account.
2. Decide whether Cockpit Files or Tailscale SSH should be the default day-to-day path.
3. Keep the Oracle VM and local aVM on the same toolset.
4. Leave the public handoff pointing at this status page and the live control plane plan.
