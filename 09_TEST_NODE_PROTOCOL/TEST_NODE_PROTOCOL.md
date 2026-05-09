# CMCB Test Node Protocol

## VM → desktop/laptop

VM writes `CMCB_TEST_REQUEST` packets into:

```text
CMCB-Shared/test_requests/desktop/
CMCB-Shared/test_requests/laptop/
```

## desktop/laptop → VM

Local test node writes `CMCB_TEST_RESULT` packets into:

```text
CMCB-Shared/test_results/desktop/
CMCB-Shared/test_results/laptop/
```

## Local agent allowed test types

- file_inventory
- artifact_presence
- minecraft_client_manual
- minecraft_log_collect
- visual_manual
- custom_script only if explicitly allowlisted

## Stop conditions

- admin prompt
- credential prompt
- destructive command
- unknown download
- timeout
- missing artifact
- manual review required
