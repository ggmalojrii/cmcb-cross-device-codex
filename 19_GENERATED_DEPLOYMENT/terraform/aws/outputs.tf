output "instance_id" {
  value = aws_instance.cmcb.id
}

output "public_ip" {
  value = aws_instance.cmcb.public_ip
}

output "public_dns" {
  value = aws_instance.cmcb.public_dns
}

output "ssh_policy" {
  value = length(var.allowed_ssh_cidr) == 0 ? "No public SSH ingress configured." : "Temporary public SSH ingress configured. Remove after Tailscale works."
}

output "next_step" {
  value = "Use provider console or approved SSH to run 19_GENERATED_DEPLOYMENT/scripts/bootstrap_vm.sh, then enroll Tailscale."
}

