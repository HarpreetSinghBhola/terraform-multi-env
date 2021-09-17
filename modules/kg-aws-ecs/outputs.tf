#------------------------------------------------------------------------------
# ECS CLUSTER
#------------------------------------------------------------------------------
output "aws_ecs_cluster_cluster_name" {
  description = "The name of the cluster"
  value       = aws_ecs_cluster.fargate_cluster.name
}

output "aws_ecs_cluster_cluster_arn" {
  description = "The Amazon Resource Name (ARN) that identifies the cluster"
  value       = aws_ecs_cluster.fargate_cluster.arn
}

#------------------------------------------------------------------------------
# AWS ECS Task Execution Role
#------------------------------------------------------------------------------
output "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) specifying the ECS execution role."
  value       = aws_iam_role.execution.arn
}

output "execution_role_name" {
  description = "The name of the ECS execution role."
  value       = aws_iam_role.execution.name
}