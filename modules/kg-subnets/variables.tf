variable "private_subnets" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
}
variable "azs" {
  description = "A list of availability zones names or ids in the region"
  type        = list(string)
  default     = []
}
variable "create_vpc" {
  description = "Controls if VPC should be created (it affects almost all resources)"
  type        = bool
  default     = true
}
variable "enable_nat_gateway" {
  description = "Should be true if you want to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}
variable "one_nat_gateway_per_az" {
  description = "Should be true if you want only one NAT Gateway per availability zone. Requires `var.azs` to be set, and the number of `public_subnets` created to be greater than or equal to the number of availability zones specified in `var.azs`."
  type        = bool
  default     = false
}
variable "single_nat_gateway" {
  description = "Should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  type        = bool
  default     = false
}
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}
variable "private_subnet_suffix" {
  description = "Suffix to append to private subnets name"
  type        = string
  default     = "private"
}
variable "private_route_table_tags" {
  description = "Additional tags for the private route tables"
  type        = map(string)
  default     = {}
}
variable "name" {
  description = "Name of the Resource" 
  type        = string
}
######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
variable "state_bucket_name_vpc" {
  default     = ""
  type        = string
  description = "Bucket Name for remote s3 state file, to fetch the resource details"
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "account_id" {
  type = string
}
######## Variables Used in Tagging the Resources
variable "environment_name" {
  default     = "dev"
  type        = string
  description = "The name of Environment to which Resources belongs i.e. prod, qa, or dev"
}
variable "contact_name" {
  type        = string
  description = "Contact Person Name"
}
variable "product_name" {
  default     = ""
  type        = string
  description = "Product Name used in tags"
}