variable "enable_execute_command" {
  type        = bool
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service."
  default     = true
}

variable "cluster_name" {
  default     = "kyckg"
  type        = string
  description = "The name of Cluster to Resources"
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