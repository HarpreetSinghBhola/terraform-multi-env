#####
# IAM - Task execution role
#####
resource "aws_iam_role" "execution" {
  name               = "${var.environment_name}-${var.cluster_name}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json

  tags = local.tags
}

resource "aws_iam_role_policy" "task_execution" {
  name   = "${var.environment_name}-${var.cluster_name}-task-execution"
  role   = aws_iam_role.execution.id
  policy = data.aws_iam_policy_document.task_execution_permissions.json
}

resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = aws_iam_role.execution.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#####
# IAM - Task role
#####
resource "aws_iam_role" "task" {
  name               = "${var.environment_name}-${var.cluster_name}-task-role"
  assume_role_policy = data.aws_iam_policy_document.task_assume.json

  tags = local.tags
}

resource "aws_iam_role_policy" "log_agent" {
  name   = "${var.environment_name}-${var.cluster_name}-log-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_permissions.json
}

resource "aws_iam_role_policy" "ecs_exec_inline_policy" {
  count = var.enable_execute_command ? 1 : 0

  name   = "${var.environment_name}-${var.cluster_name}-ecs-exec-permissions"
  role   = aws_iam_role.task.id
  policy = data.aws_iam_policy_document.task_ecs_exec_policy[0].json
}

### ECS CLUSTER CREATE
resource "aws_ecs_cluster" "fargate_cluster" {
  name = "${var.environment_name}-${var.cluster_name}"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = local.tags
}

