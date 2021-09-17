variable "clients" {  
  description = "A list of client certificate name"
  type        = list(string)
  default = ["client"]
}

variable "cert_issuer" { 
  description = "Common Name for CA Certificate"
  type        = string
  default = "CA"
}

variable "cert_server_name" { 
  description = "Name for the Server Certificate"
  type        = string
  default = "kyckglobal"
}

variable "aws_tenant_name" {
  description = "Name for the AWS Tenant"
  type        = string 
  default = "AWS"
}

variable "key_save_folder" {
  description = "Where to store keys (relative to pki folder)"
  type        = string 
  default     = "clientvpn_keys"
}

variable "subnet_ids" {
  description = "The subnet ID to which we need to associate the VPN Client Connection."
  type        = list(string)
  default     = []
}

variable "client_cidr_block" {
  description = "VPN CIDR block, must not overlap with VPC CIDR. Client cidr block must be at least a /22 range."
  type        = string
}

variable "target_cidr_block" {
  description = "The CIDR block to wich the client will have access to. Might be VPC CIDR's block for example."
  type        = string
}

variable "dns_servers" {
  description = "Information about the DNS servers to be used for DNS resolution. A Client VPN endpoint can have up to two DNS servers."
  type        = list(string)
  default     = null
}

variable "vpn_name" {
  description = "The name of the VPN Client Connection."
  type        = string
  default     = "VPN"
}

variable "cloudwatch_enabled" {
  description = "Indicates whether connection logging is enabled."
  type = bool
  default = true
}

variable "cloudwatch_log_group" {
  description = "The name of the cloudwatch log group."
  type        = string
  default = "vpn_endpoint_cloudwatch_log_group"
}

variable "cloudwatch_log_stream" {
  description = "The name of the cloudwatch log stream."
  type        = string
  default = "vpn_endpoint_cloudwatch_log_stream"
}

variable "aws_cli_profile_name" {
  description = "The name of the aws cli profile used in scripts"
  type        = string
  default     = "default"
}

variable "client_auth" {
  description = "the type of client authentication to be used : certificate-authentication / directory-service-authentication / federated-authentication"
  type        = string
  default     = "certificate-authentication"
}

variable "active_directory_id" {
  description = "The ID of the Active Directory to be used for authentication if type is directory-service-authentication"
  type        = string
  default     = null
}

variable "root_certificate_chain_arn" {
  description = "The ARN of the client certificate. The certificate must be signed by a certificate authority (CA) and it must be provisioned in AWS Certificate Manager (ACM). Only necessary when type is set to certificate-authentication."
  type        = string
  default = null
}

variable "saml_provider_arn" {
  description = "The ARN of the IAM SAML identity provider if type is federated-authentication"
  type        = string
  default     = null
}

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
variable "state_bucket_name_vpc" {
  default     = ""
  type        = string
  description = "Bucket Name for remote s3 state file, to fetch the resource details"
}

variable "ovpn_file_bucket_name" {
  default     = ""
  type        = string
  description = "Bucket Name for remote s3 state file, to fetch the resource details"
}

######## Variables Used in Tagging the Resources
variable "env" {
  default     = "ops"
  type        = string
  description = "The name of Environment to which Resources belongs i.e. prod, qa, or dev"
}
variable "environment_name" {
  default     = ""
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
variable "region" {
  type = string
  default = "us-east-1"
}
variable "account_id" {
  type = string
}
variable "logs_retention" {
  default     = 365
  description = "Retention in days for CloudWatch Log Group"
}