# Terraform Templates

These files are templates only. Do not run `terraform apply` until provider, size, budget, SSH key, and network exposure are approved.

## Provider Status

Cloud provider has not been selected for any paid path. The `aws/` folder remains a starter template for review, and `oracle/` is the free-tier mirror path that matches the current local-first roadmap.

## Secrets

Do not put secrets into `terraform.tfvars`.

Prefer environment variables:

```bash
export AWS_PROFILE=""
export AWS_REGION=""
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
export OCI_TENANCY_OCID=""
export OCI_USER_OCID=""
export OCI_FINGERPRINT=""
export OCI_PRIVATE_KEY_PATH=""
export OCI_COMPARTMENT_OCID=""
export OCI_REGION=""
```

Avoid passing Tailscale auth keys through Terraform unless the final provider-specific secret handling design is approved.

## Safe Commands

Plan-only:

```bash
cd 19_GENERATED_DEPLOYMENT/terraform/aws
terraform init
terraform validate
terraform plan
```

Oracle free-tier mirror path:

```bash
cd 19_GENERATED_DEPLOYMENT/terraform/oracle
terraform init
terraform validate
terraform plan
```

Apply is blocked until explicitly approved:

```bash
terraform apply
```
