# Cross-Device Architecture

## Target topology

```text
Desktop / Laptop / iPhone / iPad
        |
        | private network: Tailscale
        v
Cloud VM
  - Codex CLI
  - Java/Gradle/build tools
  - CMCB v18.26 drop-in
  - project repos
  - server/test harnesses
  - test request orchestrator
        |
        | synced artifacts/logs: Syncthing/rclone/Git
        v
Desktop/Laptop local test nodes
```

## Why this split works

- VM is always-on and handles long builds/server tests.
- Desktop/laptop run tests that need local OS, GPU, Minecraft client, launcher, or local files.
- iDevices are control/review clients, not heavy workers.
- CMCB packets keep state portable and auditable.
