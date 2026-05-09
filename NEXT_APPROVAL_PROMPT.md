# Next Approval Prompt

Reply with the approved values before any cloud deployment, paid action, admin install, credential operation, or firewall exposure.

## Required Approval Values

```text
APPROVE PLAN: yes/no

Cloud provider:
- Oracle Cloud Infrastructure if you want the free mirror path
Region:
VM size:
Disk size:
Monthly budget ceiling:
SSH public key path or public key text:

Allow Terraform plan: yes/no
Allow Terraform apply: yes/no

Allow temporary public SSH ingress: yes/no
If yes, approved CIDR:

Tailscale enrollment:
- auth key via environment variable, or
- interactive login from VM console/SSH

Allow VM sudo package installs: yes/no
Allow Codex CLI install on VM: yes/no

Local free aVM / WSL:
- allow WSL Ubuntu 24.04 install with Windows UAC: yes/no
- allow Ubuntu apt installs inside WSL: yes/no
- allow Codex CLI install inside WSL: yes/no

Oracle free mirror path:
- tenancy OCID provided: yes/no
- user OCID provided: yes/no
- fingerprint provided: yes/no
- private key path provided: yes/no
- compartment OCID provided: yes/no
- Ubuntu 24.04 image OCID provided: yes/no
- allow Oracle Terraform plan: yes/no
- allow Oracle Terraform apply: yes/no

Artifact/log sync:
- Syncthing, rclone, or manual shared folder

Git repo URL(s):

Desktop local test node:
- prepare folder tree: yes/no
- install missing tools through admin manifest: yes/no
- start local test agent: yes/no

Laptop local test node:
- prepare folder tree: yes/no
- install missing tools through admin manifest: yes/no
- start local test agent: yes/no

iPhone/iPad control:
- Tailscale installed/logged in: yes/no
- preferred SSH/review app:
```

## Safe First Approval

The lowest-risk next approval is:

```text
Approve Terraform plan only, no apply.
Approve local folder-tree creation only, no admin installs.
Approve no public SSH unless CIDR is provided.
Approve local aVM readiness check only, no WSL install and no apt installs.
Approve Oracle Always Free plan only, no apply.
```
