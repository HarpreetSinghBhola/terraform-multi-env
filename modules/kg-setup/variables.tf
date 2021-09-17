variable "s3_bucket_backend_name" {
  description = "A list of S3 bucket for tf state"
  type        = list(string)
  default     = []
}

variable "enable_versioning" {
  description = "Should be true if you want versioning on s3 bucket used for tf state"
  type        = bool
  default     = true
}
variable "encryption_sse_algorithm" {
  description = "Name of encryption_sse_algorithm"
  type        = string
  default     = "private"
}
variable "table_name" {
  description = "DynamoDB Table name used for locking the tf state file" 
  type        = string
}
######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
variable "hash_key" {
  default     = ""
  type        = string
  description = "he attribute to use as the hash (partition) key"
}
variable "region" {
  type = string
  default = "us-east-1"
}
variable "account_id" {
  type = string
}
######## Variables Used in Tagging the Resources
variable "contact_name" {
  type        = string
  description = "Contact Person Name"
}
variable "product_name" {
  default     = ""
  type        = string
  description = "Product Name used in tags"
}