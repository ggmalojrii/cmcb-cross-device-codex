# Cloud VM Setup

## Recommended VM

```text
OS: Ubuntu 24.04 LTS
CPU: 4–8 vCPU minimum; 8+ preferred
RAM: 16–32 GB
Disk: 200–500 GB SSD
Network: Tailscale private access
```

## Install

Run:

```bash
bash 13_SCRIPTS/bootstrap_cloud_vm.sh
```

## Recommended directories

```text
~/cmcb-work/
  projects/
  shared/
    CMCB-Shared/
      test_requests/
      test_results/
      artifacts/
      logs/
      screenshots/
      handoffs/
      cmcb_sync/
```

## Start Codex

```bash
cd ~/cmcb-work/projects/ProjectName
codex
```

First prompt:

```text
Follow AGENTS.md. Initialize CMCB sync, inventory this project, detect source files, CMCB archives, Gradle files, logs, and server/test assets. Report current state. Do not edit files yet.
```
