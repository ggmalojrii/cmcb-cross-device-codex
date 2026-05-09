# SSH Setup Notes

Use SSH public keys only.

Do not store private keys in this package, Git, CMCB packets, logs, or shared folders.

## VM Access

Preferred after setup:

```bash
ssh ubuntu@<tailscale-name-or-tailnet-ip>
```

Temporary public SSH should be used only if explicitly approved and limited to a narrow CIDR. After Tailscale works, remove temporary public SSH ingress.

## Public Key

Provide only the public key:

```bash
cat ~/.ssh/id_ed25519.pub
```

Terraform variable:

```bash
export TF_VAR_ssh_public_key="$(cat ~/.ssh/id_ed25519.pub)"
```

