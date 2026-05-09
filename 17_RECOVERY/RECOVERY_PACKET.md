# Recovery Packet — CMCB-v18.27-cross-device-vm-codex-environment-setup

Core reconstruction:

- AGENTS.md
- NODE_REGISTRY.json
- 13_SCRIPTS/vm_orchestrator.py
- 13_SCRIPTS/local_test_agent.py
- 13_SCRIPTS/admin_install_manager.py
- 13_SCRIPTS/run_admin_install_windows.ps1
- 11_ADMIN_INSTALLS/ADMIN_INSTALL_MANIFEST.json
- 12_TEMPLATES/CMCB_TEST_REQUEST.schema.json
- 12_TEMPLATES/CMCB_TEST_RESULT.schema.json

Core rule:
Cloud VM orchestrates. Desktop/laptop local agents test only from explicit allowlisted packets. Admin installs require explicit manifest + user approval. iDevices control/review only.
