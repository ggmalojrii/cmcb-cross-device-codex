# Windows Desktop/Laptop Test Node Setup

## Purpose

Make a Windows desktop/laptop available as a controlled local test node.

## Install requirements

- Tailscale
- Python 3
- Git
- Syncthing or shared folder setup
- Optional: Java 21, Minecraft launcher/test profile, VS Code

## Bootstrap

```powershell
powershell -ExecutionPolicy Bypass -File .\13_SCRIPTS\bootstrap_windows_test_node.ps1
```

## Start local test agent

Desktop:

```powershell
python .\13_SCRIPTS\local_test_agent.py --node-id desktop --shared-root .\shared\CMCB-Shared
```

Laptop:

```powershell
python .\13_SCRIPTS\local_test_agent.py --node-id laptop --shared-root .\shared\CMCB-Shared
```

## Rules

- Agent only runs allowlisted test types.
- Agent does not run admin installs unless admin install manifest allows it and user approves UAC.
- Results go to `test_results/<node>/`.
