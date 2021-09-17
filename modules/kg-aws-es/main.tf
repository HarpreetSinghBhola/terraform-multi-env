resource "aws_security_group" "default" {
  count       = var.enabled && var.vpc_enabled ? 1 : 0
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  name        = "es-sgs"
  description = "Allow inbound traffic from Security Groups and CIDRs. Allow all outbound traffic"
  tags = merge(
    {
      "Name" = "${var.es_domain_name}-sg"
    },
    local.tags,
  )
}

resource "aws_security_group_rule" "ingress_security_groups" {
  count                    = var.enabled && var.vpc_enabled ? length(var.security_groups) : 0
  description              = "Allow inbound traffic from Security Groups"
  type                     = "ingress"
  from_port                = var.ingress_port_range_start
  to_port                  = var.ingress_port_range_end
  protocol                 = "tcp"
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "ingress_cidr_blocks" {
  count             = var.enabled && var.vpc_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = var.ingress_port_range_start
  to_port           = var.ingress_port_range_end
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

### Allow VPN CIDR Access
resource "aws_security_group_rule" "vpn_ingress_cidr_blocks" {
  count             = var.enabled && var.vpc_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow inbound traffic from CIDR blocks"
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = var.vpn_allowed_cidr_blocks
  security_group_id = join("", aws_security_group.default.*.id)
}

resource "aws_security_group_rule" "egress" {
  count             = var.enabled && var.vpc_enabled ? 1 : 0
  description       = "Allow all egress traffic"
  type              = "egress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = join("", aws_security_group.default.*.id)
}

# https://github.com/terraform-providers/terraform-provider-aws/issues/5218
resource "aws_iam_service_linked_role" "default" {
  count            = var.enabled && var.create_iam_service_linked_role ? 1 : 0
  aws_service_name = "es.amazonaws.com"
  description      = "AWSServiceRoleForAmazonElasticsearchService Service-Linked Role"
}

# Role that pods can assume for access to elasticsearch and kibana
#&& (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
resource "aws_iam_role" "elasticsearch_user" {
  count              = var.enabled ? 1 : 0
  name               = var.es_domain_name
  assume_role_policy = join("", data.aws_iam_policy_document.assume_role.*.json)
  description        = "IAM Role to assume to access the Elasticsearch cluster"
  tags = merge(
    {
      "Name" = "${var.es_domain_name}-es-user-role"
    },
    local.tags,
  )

  max_session_duration = var.iam_role_max_session_duration
}

#&& (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
data "aws_iam_policy_document" "assume_role" {
  count = var.enabled ? 1 : 0
  statement {
    actions = [
      "sts:AssumeRole"
    ]

    principals {
      type        = "Service"
      identifiers = var.aws_ec2_service_name
    }

    principals {
      type        = "AWS"
      identifiers = compact(concat(var.iam_authorizing_role_arns, var.iam_role_arns))
    }

    effect = "Allow"
  }
}

resource "aws_cloudwatch_log_group" "cloudwatch_publishing_index" {
  count             = var.enabled && var.log_publishing_index_enabled ? 1 : 0
  name              = "/aws/es/publishing-index/logs"
  tags              = local.tags
  retention_in_days = var.logs_retention

}
resource "aws_cloudwatch_log_group" "cloudwatch_publishing_search" {
  count             = var.enabled && var.log_publishing_search_enabled ? 1 : 0
  name              = "/aws/es/publishing-search/logs"
  tags              = local.tags
  retention_in_days = var.logs_retention

}
resource "aws_cloudwatch_log_group" "cloudwatch_publishing_audit" {
  count             = var.enabled && var.log_publishing_audit_enabled ? 1 : 0
  name              = "/aws/es/publishing-audit/logs"
  tags              = local.tags
  retention_in_days = var.logs_retention

}
resource "aws_cloudwatch_log_group" "cloudwatch_publishing_application" {
  count             = var.enabled && var.log_publishing_application_enabled ? 1 : 0
  name              = "/aws/es/publishing-application/logs"
  tags              = local.tags
  retention_in_days = var.logs_retention

}
resource "aws_cloudwatch_log_resource_policy" "cloudwatch_policy" {
  count           = var.enabled && var.log_publishing_index_enabled ? 1 : 0
  policy_document = data.aws_iam_policy_document.elasticsearch-log-publishing-policy.json
  policy_name     = "elasticsearch-log-publishing-policy"
}

data "aws_iam_policy_document" "elasticsearch-log-publishing-policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]
    resources = ["arn:aws:logs:*"]
    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_elasticsearch_domain" "default" {
  count                 = var.enabled ? 1 : 0
  depends_on            = [aws_iam_service_linked_role.default,aws_cloudwatch_log_group.cloudwatch_publishing_application,aws_cloudwatch_log_group.cloudwatch_publishing_audit, aws_cloudwatch_log_group.cloudwatch_publishing_search, aws_cloudwatch_log_group.cloudwatch_publishing_index]
  domain_name           = var.es_domain_name
  elasticsearch_version = var.elasticsearch_version

  advanced_options = var.advanced_options

  advanced_security_options {
    enabled                        = var.advanced_security_options_enabled
    internal_user_database_enabled = var.advanced_security_options_internal_user_database_enabled
    master_user_options {
      master_user_arn      = var.advanced_security_options_master_user_arn
      master_user_name     = var.advanced_security_options_master_user_name
      master_user_password = var.advanced_security_options_master_user_password
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
    iops        = var.ebs_iops
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest_enabled
    kms_key_id = var.encrypt_at_rest_kms_key_id
  }

  domain_endpoint_options {
    enforce_https                   = var.domain_endpoint_options_enforce_https
    tls_security_policy             = var.domain_endpoint_options_tls_security_policy
    custom_endpoint_enabled         = var.custom_endpoint_enabled
    custom_endpoint                 = var.custom_endpoint_enabled ? var.custom_endpoint : null
    custom_endpoint_certificate_arn = var.custom_endpoint_enabled ? var.custom_endpoint_certificate_arn : null
  }

  cluster_config {
    instance_count           = var.instance_count
    instance_type            = var.instance_type
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
    zone_awareness_enabled   = var.zone_awareness_enabled
    warm_enabled             = var.warm_enabled
    warm_count               = var.warm_enabled ? var.warm_count : null
    warm_type                = var.warm_enabled ? var.warm_type : null

    dynamic "zone_awareness_config" {
      for_each = var.availability_zone_count > 1 ? [true] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption_enabled
  }

  vpc_options {
    subnet_ids = [
      data.terraform_remote_state.vpc.outputs.private_subnets[0],
      data.terraform_remote_state.vpc.outputs.private_subnets[1],
    ]

    security_group_ids = [join("", aws_security_group.default.*.id)]
  }
/*
  # dynamic "vpc_options" {
  #   for_each = var.vpc_enabled ? [true] : []

  #   content {
  #     security_group_ids = [join("", aws_security_group.default.*.id)]
  #     subnet_ids         = var.subnet_ids
  #   }
  # }
*/
  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }
/*
  dynamic "cognito_options" {
    for_each = var.cognito_authentication_enabled ? [true] : []
    content {
      enabled          = true
      user_pool_id     = var.cognito_user_pool_id
      identity_pool_id = var.cognito_identity_pool_id
      role_arn         = var.cognito_iam_role_arn
    }
  }
*/
  log_publishing_options {
    enabled                  = var.log_publishing_index_enabled
    log_type                 = "INDEX_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cloudwatch_publishing_index[0].arn
  }

  log_publishing_options {
    enabled                  = var.log_publishing_search_enabled
    log_type                 = "SEARCH_SLOW_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cloudwatch_publishing_search[0].arn
  }

  # log_publishing_options {
  #   enabled                  = var.log_publishing_audit_enabled
  #   log_type                 = "AUDIT_LOGS"
  #   cloudwatch_log_group_arn = aws_cloudwatch_log_group.cloudwatch_publishing_audit[0].arn
  # }

  log_publishing_options {
    enabled                  = var.log_publishing_application_enabled
    log_type                 = "ES_APPLICATION_LOGS"
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.cloudwatch_publishing_application[0].arn
  }

  tags = local.tags

}

#&& (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
data "aws_iam_policy_document" "default" {
  count = var.enabled ? 1 : 0

  statement {
    effect = "Allow"

    actions = distinct(compact(var.iam_actions))

    resources = [
      join("", aws_elasticsearch_domain.default.*.arn),
      "${join("", aws_elasticsearch_domain.default.*.arn)}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }

  # This statement is for non VPC ES to allow anonymous access from whitelisted IP ranges without requests signing
  # https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/es-ac.html#es-ac-types-ip
  # https://aws.amazon.com/premiumsupport/knowledge-center/anonymous-not-authorized-elasticsearch/
  dynamic "statement" {
    for_each = length(var.allowed_cidr_blocks) > 0 && ! var.vpc_enabled ? [true] : []
    content {
      effect = "Allow"

      actions = distinct(compact(var.iam_actions))

      resources = [
        join("", aws_elasticsearch_domain.default.*.arn),
        "${join("", aws_elasticsearch_domain.default.*.arn)}/*"
      ]

      principals {
        type        = "AWS"
        identifiers = ["*"]
      }

      condition {
        test     = "IpAddress"
        values   = var.allowed_cidr_blocks
        variable = "aws:SourceIp"
      }
    }
  }
}

#&& (length(var.iam_authorizing_role_arns) > 0 || length(var.iam_role_arns) > 0) ? 1 : 0
resource "aws_elasticsearch_domain_policy" "default" {
  count           = var.enabled ? 1 : 0
  domain_name     = var.es_domain_name
  access_policies = join("", data.aws_iam_policy_document.default.*.json)
}