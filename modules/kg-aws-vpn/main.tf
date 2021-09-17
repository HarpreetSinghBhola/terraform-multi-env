locals {
  provisioner_base_env = {
    "CERT_ISSUER"     = var.cert_issuer
    "KEY_SAVE_FOLDER" = var.key_save_folder
    "SOPS_KMS_ARN"    = aws_kms_key.sops.arn
    "REGION"          = var.region
    "ENV"             = var.environment_name
    "PKI_FOLDER_NAME" = "pki_${var.environment_name}"
    "TARGET_CIDR"     = var.target_cidr_block
    "MODULE_PATH"     = path.module
    "CONCURRENCY"     = "true"
    "AWSCLIPROFILE"   = var.aws_cli_profile_name
  }

  clients = concat(var.clients)
}

resource "aws_kms_key" "sops" {
  description = "A KMS key used by SOPS to safely store easy-rsa secrets in Git."
  
  tags = merge(map("Name", format("%s", var.vpn_name)), local.tags,)

  # tags = {
  #   "Terraform" = "true"
  # }
}

resource "null_resource" "server_certificate" {
  provisioner "local-exec" {
    environment = merge(local.provisioner_base_env, {
    })
    command = "${path.module}/scripts/prepare_easyrsa.sh"
  }
}

data "local_file" "server_private_key" {
  depends_on = [null_resource.server_certificate]
  filename = null_resource.server_certificate.id > 0 ? "pki_${var.environment_name}/${var.key_save_folder}/server.key" : ""
}

data "local_file" "server_certificate_body" {
  depends_on = [null_resource.server_certificate]
  filename = null_resource.server_certificate.id > 0 ? "pki_${var.environment_name}/${var.key_save_folder}/server.crt" : ""
}

data "local_file" "server_certificate_chain" {
  depends_on = [null_resource.server_certificate]
  filename = null_resource.server_certificate.id > 0 ? "pki_${var.environment_name}/${var.key_save_folder}/ca.crt" : ""
}

resource "aws_acm_certificate" "server_cert" {
  depends_on = [null_resource.server_certificate]

  private_key       = data.local_file.server_private_key.content
  certificate_body  = data.local_file.server_certificate_body.content
  certificate_chain = data.local_file.server_certificate_chain.content

  lifecycle {
    ignore_changes = [options, private_key, certificate_body, certificate_chain]
  }

  tags = merge(map("Name", format("%s", var.vpn_name)), local.tags,)

  # tags = {
  #   Name = var.cert_server_name
  # }
}

resource "null_resource" "client_certificate" {
  count      = length(local.clients)
  depends_on = [aws_acm_certificate.server_cert]

  provisioner "local-exec" {
    environment = merge(local.provisioner_base_env, {
      "CLIENT_CERT_NAME" = local.clients[count.index]
    })

    command = "${path.module}/scripts/create_client.sh"
  }
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  depends_on             = [aws_acm_certificate.server_cert]
  description            = var.vpn_name
  server_certificate_arn = aws_acm_certificate.server_cert.arn
  client_cidr_block      = var.client_cidr_block
  split_tunnel           = true
  dns_servers            = var.dns_servers

  lifecycle {
    ignore_changes = [server_certificate_arn, authentication_options]
  }

  authentication_options {
    type                        = var.client_auth
    active_directory_id         = var.active_directory_id
    root_certificate_chain_arn  = aws_acm_certificate.server_cert.arn
    saml_provider_arn           = var.saml_provider_arn
  }

  connection_log_options {
    enabled               = var.cloudwatch_enabled
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn.name
    cloudwatch_log_stream = aws_cloudwatch_log_stream.client_vpn.name
  }

  tags = merge(map("Name", format("%s", var.vpn_name)), local.tags,)
}

resource "aws_ec2_client_vpn_authorization_rule" "ingress-all" {
  depends_on             = [aws_ec2_client_vpn_endpoint.client_vpn]
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.target_cidr_block
  authorize_all_groups   = true
  description            = "Allow all VPN groups access to ${var.target_cidr_block}"
}

resource "aws_ec2_client_vpn_network_association" "client_vpn" {
  count                  = length(var.subnet_ids)
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = element(var.subnet_ids, count.index)
}

resource "null_resource" "export_clients_vpn_config" {
  depends_on = [null_resource.client_certificate, aws_ec2_client_vpn_endpoint.client_vpn]
  count      = length(local.clients)
  triggers = {
    client = local.clients[count.index]
  }

  provisioner "local-exec" {
    environment = merge(local.provisioner_base_env, {
      "CLIENT_VPN_ID"    = aws_ec2_client_vpn_endpoint.client_vpn.id,
      "CLIENT_CERT_NAME" = local.clients[count.index],
      "TENANT_NAME" = var.aws_tenant_name
      "AWS_REGION"  = var.region
    })
    command = "${path.module}/scripts/export_client_vpn_config.sh"
  }
}

resource "aws_cloudwatch_log_group" "client_vpn" {
  name              = "/aws/vpn/${var.vpn_name}/logs"
  retention_in_days = var.logs_retention

  tags = merge(map("Name", format("%s", var.vpn_name)), local.tags,)
}

resource "aws_cloudwatch_log_stream" "client_vpn" {
  name           = var.cloudwatch_log_stream
  log_group_name = aws_cloudwatch_log_group.client_vpn.name
}


### VPN Config Upload to S3

resource "aws_s3_bucket_object" "pki_config" {
  depends_on = [null_resource.export_clients_vpn_config]
  for_each = fileset("pki_${var.environment_name}/", "**")
  bucket = var.ovpn_file_bucket_name
  key = "certs/${var.environment_name}/${each.value}"
  source = "pki_${var.environment_name}/${each.value}"
}

resource "aws_s3_bucket_object" "client_vpn_file" {
  depends_on = [null_resource.export_clients_vpn_config]
  for_each = fileset("./", "**.ovpn")
  bucket = var.ovpn_file_bucket_name
  key = "certs/clients-ovpn-file/${var.environment_name}/${each.value}"
  source = "./${each.value}"
  # etag = filemd5("./${each.value}")
}