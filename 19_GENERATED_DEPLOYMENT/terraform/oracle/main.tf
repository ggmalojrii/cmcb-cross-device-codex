provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
  region           = var.region
}

locals {
  common_tags = merge(
    {
      Name      = var.instance_name
      Role      = "CMCB_Codex_VM_Orchestrator"
      ManagedBy = "Terraform"
      Network   = "Oracle Always Free"
    },
    var.tags
  )
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

resource "oci_core_vcn" "cmcb" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr_block]
  display_name   = var.network_name
  dns_label      = var.vcn_dns_label
  freeform_tags  = local.common_tags
}

resource "oci_core_internet_gateway" "cmcb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cmcb.id
  display_name   = "${var.network_name}-igw"
  enabled        = true
  freeform_tags  = local.common_tags
}

resource "oci_core_route_table" "cmcb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cmcb.id
  display_name   = "${var.network_name}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.cmcb.id
  }

  freeform_tags = local.common_tags
}

resource "oci_core_security_list" "cmcb" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.cmcb.id
  display_name   = "${var.network_name}-sl"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  freeform_tags = local.common_tags
}

resource "oci_core_subnet" "cmcb" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.cmcb.id
  cidr_block                 = var.subnet_cidr_block
  display_name               = "${var.network_name}-subnet"
  dns_label                  = var.subnet_dns_label
  route_table_id             = oci_core_route_table.cmcb.id
  security_list_ids          = [oci_core_security_list.cmcb.id]
  prohibit_public_ip_on_vnic = false
  freeform_tags              = local.common_tags
}

resource "oci_core_instance" "cmcb" {
  compartment_id      = var.compartment_ocid
  display_name        = var.instance_name
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  shape               = var.shape

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.cmcb.id
    assign_public_ip = var.assign_public_ip
    hostname_label   = var.hostname_label
    display_name     = "${var.instance_name}-vnic"
  }

  source_details {
    source_type = "image"
    source_id   = var.image_ocid

    boot_volume_size_in_gbs = var.boot_volume_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(file("${path.module}/../../cloud-init/cloud-init.yaml"))
  }

  freeform_tags = local.common_tags
}
