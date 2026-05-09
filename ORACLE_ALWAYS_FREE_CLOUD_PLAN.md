# Oracle Always Free Cloud Plan

## Why Oracle

Oracle Cloud Always Free is the free-cloud mirror path for this roadmap. It keeps the local aVM as the primary worker and uses cloud only when a second always-on Linux VM is useful.

## Operating Model

- Primary worker: local aVM on this PC.
- Secondary worker: Oracle Always Free Ubuntu 24.04 VM.
- Network: Tailscale private access only.
- Public ports: closed by default.
- Source sync: Git.
- Artifact/log sync: Syncthing or rclone, never secrets.

## Oracle Inputs Still Needed

- Oracle tenancy OCID.
- Oracle user OCID.
- Oracle fingerprint.
- Oracle private key path for the OCI provider.
- Oracle compartment OCID.
- Region.
- Approved SSH public key.
- Oracle Ubuntu 24.04 image OCID, or a console-selected image reference.
- Terraform plan/apply approval.
- Tailscale auth key or interactive login.

## Free-Tier Shape

Preferred:

- Shape: `VM.Standard.A1.Flex`
- OCPUs: `1`
- Memory: `6 GB`

Fallback:

- Smaller A1 Flex shape if capacity is tight.
- Micro shape only if the free-tier A1 capacity is unavailable.

## Bootstrap Flow

1. Create the Oracle VCN, subnet, security list, and instance through Terraform.
2. Keep inbound rules closed except for Tailscale-private use later.
3. Run `19_GENERATED_DEPLOYMENT/scripts/bootstrap_vm.sh` on the VM.
4. Enroll Tailscale.
5. Install Codex only after Node/npm is available.
6. Create the CMCB folder tree.
7. Clone approved Git repos.
8. Validate the environment.

## Local-First Advantage

The Oracle VM is optional. The PC-local aVM already covers the free worker path, so Oracle is only needed if you want a second Linux worker outside the house.
