# Node Roles

## VM_ORCHESTRATOR

- Runs Codex CLI.
- Builds/packages code.
- Runs server-side tests.
- Creates TEST_REQUEST packets.
- Collects TEST_RESULT packets.
- Generates CMCB sync packets for Central Chat.

## DESKTOP_TEST_NODE

- Runs desktop-specific tests.
- Runs Minecraft client/launcher tests when configured.
- Captures logs/screenshots.
- Returns test results.

## LAPTOP_TEST_NODE

- Same as desktop, usually secondary/mobile/local validation.

## IDEVICE_CONTROL

- Uses Tailscale + SSH app/browser dashboard.
- Reviews reports and triggers safe commands.
- Does not run heavy tests.

## CHATGPT_CENTRAL

- Command center and CMCB review/relay hub.
