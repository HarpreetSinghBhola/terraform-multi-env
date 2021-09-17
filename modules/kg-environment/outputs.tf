# Account outputs
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}
# VPC outputs
output "region" {
  value = var.region
}
output "vpc_id" {
  value = module.infra.vpc_id
}
output "vpc_cidr_block" {
  value = module.infra.vpc_cidr_block
}
output "vpc_azs" {
  value = module.infra.vpc_azs
}
output "private_subnets" {
  value = module.infra.private_subnets
}
output "public_subnets" {
  value = module.infra.public_subnets
}
output "natgw_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.infra.natgw_ids
}
