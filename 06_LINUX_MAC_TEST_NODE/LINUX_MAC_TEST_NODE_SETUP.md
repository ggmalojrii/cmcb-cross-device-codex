# Linux/macOS Test Node Setup

## Bootstrap

```bash
python3 -m venv .venv
. .venv/bin/activate
python 13_SCRIPTS/local_test_agent.py --node-id laptop --shared-root ./shared/CMCB-Shared
```

For Linux packages requiring sudo, use the admin install manifest and review before running.
