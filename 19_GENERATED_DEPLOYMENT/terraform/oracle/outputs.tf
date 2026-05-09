output "instance_id" {
  value = oci_core_instance.cmcb.id
}

output "public_ip" {
  value = oci_core_instance.cmcb.public_ip
}

output "private_ip" {
  value = oci_core_instance.cmcb.private_ip
}

output "subnet_id" {
  value = oci_core_subnet.cmcb.id
}

output "next_step" {
  value = "Use Tailscale or approved SSH to run 19_GENERATED_DEPLOYMENT/scripts/bootstrap_vm.sh, then enroll the Oracle VM in the tailnet."
}

output "public_ingress_policy" {
  value = "Inbound rules are closed by default; the instance is intended for Tailscale-only access after bootstrap."
}
