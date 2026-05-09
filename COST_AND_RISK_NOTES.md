# Cost And Risk Notes

## Cost Drivers

Cloud provider pricing depends on region and exact instance family. With the recommended shape:

- 4 vCPU / 16 GB RAM / 200 GB SSD may often land in a moderate monthly cost range.
- 8 vCPU / 32 GB RAM / 300-500 GB SSD can become meaningfully more expensive.
- Persistent disks, snapshots, backups, static IPs, bandwidth, and managed firewalls may add cost.
- Oracle Always Free can reduce spend, but capacity limits still apply and free resources can be unavailable in a region.

Set an explicit monthly budget before creating resources.

## Main Risks

- Paid cloud resources can continue billing if left running.
- Public SSH exposure increases attack surface.
- Cloud-init metadata can leak secrets if auth keys are embedded.
- Terraform state can contain sensitive values.
- Oracle or other provider state can still retain OCIDs and sensitive key paths if mishandled.
- Tailscale auth keys can enroll unwanted devices if leaked.
- Syncthing/rclone can accidentally sync secrets.
- Admin installers can prompt for UAC/sudo, reboot, unknown publisher, or credentials.
- Local test packets may request behavior the test node does not allow.

## Guardrails

- No Terraform apply until provider, size, budget, and SSH key are approved.
- Public ports closed by default.
- Use Tailscale for private access.
- Use temporary SSH only with explicit approval and a narrow CIDR.
- Keep secrets in environment variables or secure stores.
- Do not write private keys, tokens, cookies, or passwords into shared folders.
- Keep `allow_admin_actions=false` until a manifest is reviewed and approved.
- Use Git branches before Codex edits.
- Validate JSON and scripts before execution.

## Recommended First Spend-Control Step

Before deployment, choose:

- Provider
- Region
- VM size
- Disk size
- Monthly budget ceiling
- Shutdown policy for idle VM
- Snapshot/backups policy

If the goal is most free and local-first, prefer:

- local aVM as primary
- Oracle Always Free as the optional cloud mirror
