variable "region" {
  description = "AWS region for the Codex worker VM."
  type        = string
}

variable "vm_name" {
  description = "Name tag for the Codex worker VM."
  type        = string
  default     = "cmcb-codex-worker"
}

variable "instance_type" {
  description = "EC2 instance type. Review cost before apply."
  type        = string
  default     = "t3.xlarge"
}

variable "root_volume_gb" {
  description = "Root disk size in GB."
  type        = number
  default     = 200
}

variable "ssh_public_key" {
  description = "Approved SSH public key text. Do not pass a private key."
  type        = string
  sensitive   = true
}

variable "allowed_ssh_cidr" {
  description = "Temporary public SSH CIDR list. Empty means no inbound SSH rule."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional AWS tags."
  type        = map(string)
  default     = {}
}

