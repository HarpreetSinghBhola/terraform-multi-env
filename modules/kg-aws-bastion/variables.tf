variable "ec2_name" {
  type = string
  description = "Bastion EC2 Instance Name"
}

variable "ssh_key_algorithm" {
  type        = string
  default     = "RSA"
  description = "SSH key algorithm"
}

variable "generate_ssh_key" {
  type        = bool
  default     = true
  description = "If set to `true`, new SSH key pair will be created"
}

variable "ec2_enabled" {
  type        = bool
  default     = true
  description = "If set to `true`, EC2 instance will be created"
}

variable "key_pair_file_bucket_name" {
  default     = ""
  type        = string
  description = "Bucket Name s3 state bucket, to upload the key-pair"
}

variable "ami" {
  type        = string
  description = "The AMI to use for the instance. By default it is the AMI provided by Amazon with Ubuntu 18.04"
  default     = ""
}
variable "instance_count" {
  description = "Number of instances to launch"
  default     = 1
  type        = string
}
variable "instance_type" {
  type        = string
  description = "The type of the instance"
  default     = "t2.micro"
}
variable "ebs_optimized" {
  type        = bool
  description = "Launched EC2 instance will be EBS-optimized"
  default     = false
}
variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}
variable "user_data" {
  type        = string
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; use `user_data_base64` instead"
  default     = null
}

variable "user_data_base64" {
  type        = string
  description = "Can be used instead of `user_data` to pass base64-encoded binary data directly. Use this instead of `user_data` whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption"
  default     = null
}
variable "instance_profile" {
  type        = string
  description = "A pre-defined profile to attach to the instance (default is to build our own)"
  default     = ""
}
variable "instance_initiated_shutdown_behavior" {
  type        = string
  description = "Specifies whether an instance stops or terminates when you initiate shutdown from the instance. Can be one of 'stop' or 'terminate'."
  default     = null
}
variable "associate_public_ip_address" {
  type        = bool
  description = "Associate a public IP address with the instance"
  default     = false
}
variable "monitoring" {
  type        = bool
  description = "Launched EC2 instance will have detailed monitoring enabled"
  default     = true
}
variable "private_ip" {
  type        = string
  description = "Private IP address to associate with the instance in the VPC"
  default     = ""
}
variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  default     = true
}
variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}
variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  default     = []
}
variable "vpn_allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of VPN CIDR blocks to be allowed to connect to the cluster"
}
variable "allowed_cidr_blocks" {
  type        = list(string)
  default     = []
  description = "List of CIDR blocks to be allowed to connect to the cluster"
}
variable "root_volume_type" {
  type        = string
  description = "Type of root volume. Can be standard, gp2 or io1"
  default     = "gp2"
}

variable "root_volume_size" {
  type        = number
  description = "Size of the root volume in gigabytes"
  default     = 10
}

variable "root_iops" {
  type        = number
  description = "Amount of provisioned IOPS. This must be set if root_volume_type is set to `io1`"
  default     = 0
}

variable "ebs_device_name" {
  type        = list(string)
  description = "Name of the EBS device to mount"
  default     = []
}
variable "volume_tags_enabled" {
  type        = bool
  default     = true
  description = "Whether or not to copy instance tags to root and EBS volumes"
}
variable "root_block_device_encrypted" {
  type        = bool
  default     = true
  description = "Whether to encrypt the root block device"
}
variable "delete_on_termination" {
  type        = bool
  description = "Whether the volume should be destroyed on instance termination"
  default     = true
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