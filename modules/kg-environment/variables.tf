# AWS settings
variable "region" {
  type = string
}
variable "name" {
  type = string
}
variable "environment_name" {
  type = string
}
variable "account_id" {
  type = string
}
variable "product_name" {
  type = string
  default = "kg-infra"
}
variable "contact_name" {
  type = string
  default = "kg-devops"
}

# VPC settings
variable "vpc_cidr" {
  type = string
}
variable "vpc_azs" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "public_subnets" {
  type = list(string)
}
