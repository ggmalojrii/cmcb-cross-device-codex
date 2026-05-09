# Laptop Node Bootstrap

Run from this folder on the laptop after installing Python/Tailscale/Syncthing:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_windows_test_node.ps1 -NodeId laptop -SharedRoot .\shared\CMCB-Shared
powershell -ExecutionPolicy Bypass -File .\validate_windows_test_node.ps1 -SharedRoot .\shared\CMCB-Shared
powershell -ExecutionPolicy Bypass -File .\run_local_test_agent.ps1 -NodeId laptop -SharedRoot .\shared\CMCB-Shared
```

Rules:
- Use Tailscale/private networking.
- Do not sync secrets.
- Start the local agent only when laptop tests are wanted.
- Stop on admin prompts, credential prompts, unknown downloads, or destructive actions.
