# AWS region name
variable "region" {
  type = string
}

# VPC CIDR block for the VPC
variable "vpc_cidr" {
  type = string
}

# List of availablity zones to use
variable "vpc_azs" {
  type = list(string)
}

# CIDR blocks for private subnets
variable "private_subnets" {
  type = list(string)
}

# CIDR blocks for public subnets
variable "public_subnets" {
  type = list(string)
}

# Additional tags for private subnets
# This is usedful for EKS deployment
variable "private_subnet_tags" {
  type    = map(string)
  default = {}
}

# Additional tags for public subnets
# This is usedful for EKS deployment
variable "public_subnet_tags" {
  type    = map(string)
  default = {}
}

# Environment name
variable "environment_name" {
  type = string
}

# Product name
variable "product_name" {
  type = string
  default = "kg-infra"
}
variable "name" {
  type = string
}
# Customer name
variable "contact_name" {
  type = string
  default = "kg-devops"
}
