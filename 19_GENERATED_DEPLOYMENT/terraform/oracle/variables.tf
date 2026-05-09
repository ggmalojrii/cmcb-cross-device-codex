variable "tenancy_ocid" {
  description = "Oracle tenancy OCID for provider authentication."
  type        = string
}

variable "user_ocid" {
  description = "Oracle user OCID for provider authentication."
  type        = string
}

variable "fingerprint" {
  description = "Oracle API key fingerprint."
  type        = string
}

variable "private_key_path" {
  description = "Local path to the Oracle API private key."
  type        = string
}

variable "compartment_ocid" {
  description = "Oracle compartment OCID for the VM."
  type        = string
}

variable "region" {
  description = "Oracle region for the free-tier VM."
  type        = string
}

variable "instance_name" {
  description = "Name for the Oracle VM."
  type        = string
  default     = "cmcb-oracle-free-worker"
}

variable "hostname_label" {
  description = "DNS label for the Oracle VNIC."
  type        = string
  default     = "cmcbfree"
}

variable "shape" {
  description = "Oracle compute shape."
  type        = string
  default     = "VM.Standard.A1.Flex"
}

variable "ocpus" {
  description = "OCPUs for the flexible shape."
  type        = number
  default     = 1
}

variable "memory_in_gbs" {
  description = "Memory in GB for the flexible shape."
  type        = number
  default     = 6
}

variable "boot_volume_gbs" {
  description = "Boot volume size in GB."
  type        = number
  default     = 50
}

variable "vcn_cidr_block" {
  description = "VCN CIDR block."
  type        = string
  default     = "10.10.0.0/16"
}

variable "subnet_cidr_block" {
  description = "Subnet CIDR block."
  type        = string
  default     = "10.10.10.0/24"
}

variable "network_name" {
  description = "Display name for the Oracle network."
  type        = string
  default     = "cmcb-free-network"
}

variable "vcn_dns_label" {
  description = "DNS label for the VCN."
  type        = string
  default     = "cmcbfreevcn"
}

variable "subnet_dns_label" {
  description = "DNS label for the subnet."
  type        = string
  default     = "cmcbfree1"
}

variable "ssh_public_key" {
  description = "Approved SSH public key text. Do not pass a private key."
  type        = string
  sensitive   = true
}

variable "image_ocid" {
  description = "Oracle Ubuntu 24.04 image OCID selected for the free-tier VM."
  type        = string
}

variable "assign_public_ip" {
  description = "Whether the instance VNIC receives a public IP for outbound internet access."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional Oracle freeform tags."
  type        = map(string)
  default     = {}
}
