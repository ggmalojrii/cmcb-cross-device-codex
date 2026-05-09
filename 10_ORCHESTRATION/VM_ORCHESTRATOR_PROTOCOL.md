# VM Orchestrator Protocol

## VM creates test request

```bash
python 13_SCRIPTS/vm_orchestrator.py create-test --target desktop --test-type file_inventory --artifact shared/CMCB-Shared/artifacts/example.txt
```

## Local test node processes request

```bash
python 13_SCRIPTS/local_test_agent.py --node-id desktop --shared-root ./shared/CMCB-Shared --once
```

## VM collects results

```bash
python 13_SCRIPTS/vm_orchestrator.py collect-results --shared-root ./shared/CMCB-Shared
```

## CMCB sync

Use CMCB v18.26 scripts for ChatGPT/Codex state sync.
