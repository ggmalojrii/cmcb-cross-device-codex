# Cloud VM Deployment Plan

## Defaults

- OS: Ubuntu 24.04 LTS
- Role: Codex orchestrator/build worker
- Network: Tailscale private access
- Public ports: closed by default
- Source sync: Git
- Artifact/log sync: Syncthing or rclone
- Admin/sudo installs: plan only until approved
- Preferred free mirror: Oracle Cloud Always Free

## Required Decisions

- Cloud provider
- Cloud region
- VM size and monthly budget
- Disk size
- SSH public key
- Whether temporary public SSH is allowed for first bootstrap
- Tailscale auth key or interactive Tailscale login
- Git repo URLs
- Syncthing or rclone for artifact/log sync

If you want the free-first cloud path, choose Oracle Cloud Infrastructure and an Always Free shape instead of a paid provider.

## Recommended VM Shape

Minimum useful worker:

- 4 vCPU
- 16 GB RAM
- 200 GB SSD

Preferred worker:

- 8 vCPU or more
- 32 GB RAM
- 300-500 GB SSD

## Secure Bootstrap Options

Option A: provider console plus private network first.

- Create VM with no public ingress.
- Use cloud provider console or serial access to run bootstrap.
- Run Tailscale login/enrollment from console.
- Use tailnet SSH afterward.

Option B: temporary narrow SSH ingress.

- Create VM with SSH open only to a single approved CIDR.
- SSH in with the approved public key.
- Run Tailscale setup.
- Verify tailnet access.
- Remove public SSH ingress immediately.

Option C: cloud-init with Tailscale auth key.

- Fully automated, but the auth key may appear in cloud-init metadata or Terraform state if handled incorrectly.
- Not recommended unless the provider-specific secret handling path is approved.

## Generated Templates

Provider-specific Terraform is available for both the generic paid-cloud path and the free Oracle mirror path.

- `19_GENERATED_DEPLOYMENT/terraform/aws`
- `19_GENERATED_DEPLOYMENT/terraform/oracle`

Treat both as templates, not approved provider execution. They keep SSH ingress empty by default and expect secrets through environment variables or interactive steps, not committed files.

## VM Bootstrap Sequence

After the VM exists and SSH or console access is available:

```bash
cd ~/cmcb-work
bash ./bootstrap_vm.sh
```

Or from this package after upload:

```bash
bash 19_GENERATED_DEPLOYMENT/scripts/bootstrap_vm.sh
```

Bootstrap behavior:

- Creates CMCB folder tree.
- Installs packages only if `CMCB_APPROVE_APT_INSTALL=1`.
- Runs Tailscale enrollment only if `CMCB_APPROVE_TAILSCALE_UP=1` and `TAILSCALE_AUTH_KEY` is set.
- Installs Codex CLI only if npm is present or approved package install has provided it.
- Writes validation reports under `reports/` and `shared/CMCB-Shared/logs/`.

## VM Folder Layout

```text
~/cmcb-work/
  projects/
  shared/
    CMCB-Shared/
      test_requests/
        desktop/
        laptop/
      test_results/
        desktop/
        laptop/
      artifacts/
      logs/
      screenshots/
      handoffs/
      cmcb_sync/
      admin_install_requests/
      admin_install_results/
```

## Codex Setup

Preferred:

```bash
npm install -g @openai/codex
```

Then:

```bash
cd ~/cmcb-work/projects/<repo>
codex
```

First prompt:

```text
Follow AGENTS.md. Initialize CMCB sync, inventory this project, detect source files, CMCB archives, Gradle files, logs, and server/test assets. Report current state. Do not edit files yet.
```

## Git Workspace

- Clone approved repos only.
- Use branches before Codex edits.
- Keep source in Git.
- Keep artifacts/logs outside source when possible.

## Gradle/Java Tools

- Use Java 21 by default.
- Prefer project wrapper `./gradlew` if present.
- Install Gradle globally only if the project lacks a wrapper and approval is granted.

## Post-Bootstrap Validation

Run:

```bash
bash 19_GENERATED_DEPLOYMENT/scripts/validate_vm_environment.sh
```

Expected before full approval:

- Git present
- Java present
- Python present
- Node/npm present
- Codex present
- Tailscale installed and logged in
- Shared folder exists
