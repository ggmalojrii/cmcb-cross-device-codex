provider "aws" {
  region = var.region
}

locals {
  common_tags = merge(
    {
      Name        = var.vm_name
      Role        = "CMCB_Codex_VM_Orchestrator"
      ManagedBy   = "Terraform"
      PublicPorts = length(var.allowed_ssh_cidr) == 0 ? "closed" : "temporary-ssh"
    },
    var.tags
  )
}

data "aws_ami" "ubuntu_2404" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "cmcb" {
  key_name   = "${var.vm_name}-key"
  public_key = var.ssh_public_key
  tags       = local.common_tags
}

resource "aws_security_group" "cmcb" {
  name        = "${var.vm_name}-sg"
  description = "CMCB Codex worker VM. Public ingress closed unless explicitly approved."

  dynamic "ingress" {
    for_each = var.allowed_ssh_cidr
    content {
      description = "Temporary approved SSH ingress"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [ingress.value]
    }
  }

  egress {
    description = "Outbound access for package install, Tailscale, Git, and Codex."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

resource "aws_instance" "cmcb" {
  ami                         = data.aws_ami.ubuntu_2404.id
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.cmcb.key_name
  vpc_security_group_ids      = [aws_security_group.cmcb.id]
  associate_public_ip_address = true
  user_data                   = file("${path.module}/../../cloud-init/cloud-init.yaml")

  root_block_device {
    volume_size = var.root_volume_gb
    volume_type = "gp3"
    encrypted   = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = local.common_tags
}

