# Oracle Terraform Template

This folder is a template for Oracle Cloud Infrastructure Always Free.

## Guardrails

- Do not run `terraform apply` until provider, region, compartment, SSH key, and any desired Tailscale enrollment method are approved.
- Keep secrets out of `terraform.tfvars`.
- Use environment variables or a local secrets manager for OCIDs and keys.
- Public ingress should stay closed by default.

## Suggested Workflow

```bash
cd 19_GENERATED_DEPLOYMENT/terraform/oracle
terraform init
terraform fmt
terraform validate
terraform plan
```

## Notes

- The Oracle VM is intended as a free mirror, not a paid production fleet.
- The existing `../../cloud-init/cloud-init.yaml` file is reused for no-secrets bootstrap.
- The existing `../../scripts/bootstrap_vm.sh` script is reused after the instance comes up.
