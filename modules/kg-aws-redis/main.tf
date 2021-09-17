resource "random_id" "redis_pg" {
  byte_length = 4
  keepers = {
    redis_version = var.redis_version
  }
}

resource "aws_elasticache_replication_group" "redis" {
  replication_group_id          = format("%.20s", "${var.environment_name}-${var.name}")
  replication_group_description = "Terraform-managed ElastiCache replication group for ${var.name}-${var.environment_name}"
  number_cache_clusters         = var.redis_clusters
  node_type                     = var.redis_node_type
  automatic_failover_enabled    = var.redis_failover
  auto_minor_version_upgrade    = var.auto_minor_version_upgrade
  availability_zones            = var.availability_zones
  multi_az_enabled              = var.multi_az_enabled
  engine                        = "redis"
  at_rest_encryption_enabled    = var.at_rest_encryption_enabled
  kms_key_id                    = var.kms_key_id
  transit_encryption_enabled    = var.transit_encryption_enabled
  auth_token                    = var.transit_encryption_enabled ? var.auth_token : null
  engine_version                = var.redis_version
  port                          = var.redis_port
  parameter_group_name          = aws_elasticache_parameter_group.redis_parameter_group.id
  subnet_group_name             = aws_elasticache_subnet_group.redis_subnet_group.id
  security_group_names          = var.security_group_names
  security_group_ids            = [aws_security_group.redis_security_group.id]
  snapshot_arns                 = var.snapshot_arns
  snapshot_name                 = var.snapshot_name
  apply_immediately             = var.apply_immediately
  maintenance_window            = var.redis_maintenance_window
  notification_topic_arn        = var.notification_topic_arn
  snapshot_window               = var.redis_snapshot_window
  snapshot_retention_limit      = var.redis_snapshot_retention_limit
  tags = merge(
    {
      "Name" = "${var.name_prefix}-redis"
    },
    local.tags,
  )
}

resource "aws_elasticache_parameter_group" "redis_parameter_group" {
  name        = "${var.name_prefix}-redis-${random_id.redis_pg.hex}"
  description = "Terraform Managed ElastiCache parameter group for ${var.name_prefix}-redis"
  # Strip the patch version from redis_version var
  family = "redis${replace(var.redis_version, "/\\.[\\d]+$/", "")}"
  dynamic "parameter" {
    for_each = var.redis_parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "${var.name_prefix}-redis-subnet"
  subnet_ids = var.subnets
}

##
# Security Group
##

resource "aws_security_group" "redis_security_group" {
  name        = "${var.name_prefix}-redis-sg"
  description = "Terraform Managed ElastiCache security group for ${var.name_prefix}-redis"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id
  tags = merge(
    {
      "Name" = "${var.name_prefix}-redis-sg"
    },
    local.tags,
  )
}

resource "aws_security_group_rule" "redis_ingress" {
  count                    = length(var.allowed_security_groups)
  type                     = "ingress"
  from_port                = var.redis_port
  to_port                  = var.redis_port
  protocol                 = "tcp"
  source_security_group_id = element(var.allowed_security_groups, count.index)
  security_group_id        = aws_security_group.redis_security_group.id
}

resource "aws_security_group_rule" "redis_networks_ingress" {
  type              = "ingress"
  from_port         = var.redis_port
  to_port           = var.redis_port
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cidr
  security_group_id = aws_security_group.redis_security_group.id
}

resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis_security_group.id
}

##
#CloudWatch Alarm For Redis
##
/*
resource "aws_cloudwatch_metric_alarm" "cache_cpu" {
  count = var.redis_clusters

  alarm_name          = "alarm-${var.name}-CacheCluster00${count.index + 1}CPUUtilization"
  alarm_description   = "Redis cluster CPU utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ElastiCache"
  period              = "300"
  statistic           = "Average"

  threshold = "${var.alarm_cpu_threshold}"

  dimensions {
    CacheClusterId = "${aws_elasticache_replication_group.redis.id}-00${count.index + 1}"
  }
}

resource "aws_cloudwatch_metric_alarm" "cache_memory" {
  count = "${var.redis_clusters}"

  alarm_name          = "alarm-${var.name}-CacheCluster00${count.index + 1}FreeableMemory"
  alarm_description   = "Redis cluster freeable memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "60"
  statistic           = "Average"

  threshold = "${var.alarm_memory_threshold}"

  dimensions {
    CacheClusterId = "${aws_elasticache_replication_group.redis.id}-00${count.index + 1}"
  }

  alarm_actions = ["${var.alarm_actions}"]
}
*/