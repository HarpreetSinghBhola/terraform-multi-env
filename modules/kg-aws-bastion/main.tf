### SSH KEY CREATION

resource "tls_private_key" "default" {
  count     = var.ec2_enabled && var.generate_ssh_key == true ? 1 : 0
  algorithm = var.ssh_key_algorithm
}

resource "aws_key_pair" "generated" {
  count     = var.ec2_enabled && var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  key_name   = "${var.ec2_name}-key"
  public_key = tls_private_key.default[0].public_key_openssh
  tags = merge(
    {
      "Name" = "${var.ec2_name}-key"
    },
    local.tags,
  )
}

resource "local_file" "public_key_openssh" {
  count      = var.ec2_enabled && var.generate_ssh_key == true ? 1 : 0
  depends_on = [tls_private_key.default]
  content    = tls_private_key.default[0].public_key_openssh
  filename   = "./${var.environment_name}-key/${var.ec2_name}-key.pub"
}

resource "local_file" "private_key_pem" {
  count             = var.ec2_enabled && var.generate_ssh_key == true ? 1 : 0
  depends_on        = [tls_private_key.default]
  sensitive_content = tls_private_key.default[0].private_key_pem
  filename          = "./${var.environment_name}-key/${var.ec2_name}-key.pem"
  file_permission   = "0600"
}


# resource "aws_s3_bucket" "my-bucket" {
# # ...

#   provisioner "local-exec" {
#      command = "aws s3 cp path_to_my_file key-pair/${var.environment_name}/"
#   }
# }

### VPN Config Upload to S3
resource "aws_s3_bucket_object" "ssh_key_pem" {
  depends_on = [local_file.private_key_pem, local_file.public_key_openssh]
  bucket     = var.key_pair_file_bucket_name
  key        = "key-pair/${var.environment_name}/${var.ec2_name}-key.pem"
  source     = "./${var.environment_name}-key/${var.ec2_name}-key.pem"
}

resource "aws_s3_bucket_object" "ssh_key_pub" {
  depends_on = [local_file.private_key_pem, local_file.public_key_openssh]
  bucket     = var.key_pair_file_bucket_name
  key        = "key-pair/${var.environment_name}/${var.ec2_name}-key.pub"
  source     = "./${var.environment_name}-key/${var.ec2_name}-key.pub"
}


data "aws_iam_policy_document" "default" {
  statement {
    sid = ""
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    effect = "Allow"
  }
}
data "aws_ami" "default" {
  count       = var.ami == "" ? 1 : 0
  most_recent = "true"
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "default" {
  count       = length(var.instance_count) > 0 ? 1 : 0
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  name        = "${var.ec2_name}-sgs"
  description = "Allow inbound traffic from Security Groups and CIDRs. Allow all outbound traffic"
  tags = merge(
    {
      "Name" = "${var.ec2_name}-sg"
    },
    local.tags,
  )
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.ec2_enabled && length(var.instance_count) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

### Allow VPN CIDR Access
resource "aws_security_group_rule" "vpn_ingress_cidr_blocks" {
  count             = var.ec2_enabled && length(var.instance_count) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.vpn_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "egress" {
  count             = var.ec2_enabled && length(var.instance_count) > 0 ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_instance" "default" {
  depends_on                           = [local_file.private_key_pem, local_file.public_key_openssh]
  count                                = var.instance_count
  ami                                  = var.ami != "" ? var.ami : join("", data.aws_ami.default.*.image_id)
  instance_type                        = var.instance_type
  ebs_optimized                        = var.ebs_optimized
  disable_api_termination              = var.disable_api_termination
  user_data                            = var.user_data
  user_data_base64                     = var.user_data_base64
  iam_instance_profile                 = var.instance_profile
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  associate_public_ip_address          = var.associate_public_ip_address
  key_name                             = "${var.ec2_name}-key"
  subnet_id                            = data.terraform_remote_state.vpc.outputs.private_subnets[0]
  monitoring                           = var.monitoring
  private_ip                           = var.private_ip
  source_dest_check                    = var.source_dest_check
  ipv6_address_count                   = var.ipv6_address_count < 0 ? null : var.ipv6_address_count
  ipv6_addresses                       = length(var.ipv6_addresses) == 0 ? null : var.ipv6_addresses
  vpc_security_group_ids               = [join("", aws_security_group.default.*.id)]

  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    delete_on_termination = var.delete_on_termination
    encrypted             = var.root_block_device_encrypted
  }

  tags = merge(local.tags, map("Name", var.instance_count > 1 ? format("%s-%d", var.ec2_name, count.index+1) : var.ec2_name))

  volume_tags = local.tags
}

