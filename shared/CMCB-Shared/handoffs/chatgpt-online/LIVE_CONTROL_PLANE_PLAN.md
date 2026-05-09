# CMCB Live Control Plane Plan

Generated: 2026-05-09

This plan picks a low-maintenance web admin stack that feels close to a lightweight cPanel for Linux while keeping the public surface closed.

## What We Found Online

### Cockpit

Cockpit is the best fit for the main web panel.

- Web-based Linux admin interface.
- Built-in terminal that behaves like a shell session.
- Storage, network, logs, services, and metrics views.
- Cockpit Files now provides browser-based file management with upload, download, rename, create directory, permissions, and editor support.

Primary sources:

- [Cockpit Project](https://cockpit-project.org/)
- [Cockpit documentation](https://cockpit-project.org/documentation.html)
- [Cockpit Terminal](https://cockpit-project.org/guide/latest/feature-terminal)
- [Cockpit Files release](https://cockpit-project.org/blog/first-cockpit-files-release.html)

### Tailscale SSH

Tailscale SSH is the best fit for secure remote SSH without public ports.

- Uses the tailnet for auth and transport.
- Keeps SSH private to the tailnet.
- Avoids static SSH key sharing for day-to-day access.

Primary sources:

- [Tailscale SSH docs](https://tailscale.com/docs/features/tailscale-ssh)
- [Tailscale SSH console](https://tailscale.com/tailscale-ssh)

### Webmin

Webmin is the fallback option if you want a more traditional admin suite.

- File manager.
- Command shell.
- Very broad system administration coverage.

Primary sources:

- [Webmin documentation](https://webmin.com/docs/)
- [Webmin File Manager](https://webmin.com/docs/modules/file-manager/)
- [Webmin Command Shell](https://webmin.com/docs/modules/command-shell/)

### Apache Guacamole

Guacamole is the browser-only SSH gateway option.

- HTML5 web app.
- Supports SSH, VNC, and RDP.
- Good when you want to reach machines from a browser without installing a local client.

Primary sources:

- [Apache Guacamole](https://guacamole.apache.org/)
- [Guacamole architecture](https://guacamole.apache.org/doc/gug/guacamole-architecture.html)

## Recommendation

Use this order:

1. **Cockpit** as the main live control panel.
2. **Cockpit Files** for safe browser-based file management.
3. **Tailscale SSH** for real remote SSH access.
4. **Guacamole** only if we later want browser-only SSH/RDP/VNC in one gateway.
5. **Webmin** only if Cockpit turns out to be missing a specific admin task.

This keeps the stack small and avoids building a custom panel from scratch.

## Where To Put It

Best first targets:

- Oracle Always Free VM
- Local aVM

That gives us one cloud node and one local node with the same admin experience.

## Safety Rules

- Do not expose the control panel publicly.
- Keep access on Tailscale only.
- Do not add password-based SSH or public SSH ports unless we explicitly decide to do that.
- Keep file editing inside the approved roots.

## Next Step

If you want this installed, the next action is a node-by-node install run:

1. Install Cockpit on the Oracle VM.
2. Install Cockpit on the local aVM.
3. Add the file management plugin and confirm the terminal.
4. Keep Tailscale SSH as the remote shell path.
5. Wire the live handoff to link to the control panel when it is up.
