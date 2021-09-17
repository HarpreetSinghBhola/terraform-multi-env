
contact_name = "kg-devops"

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"

ec2_name = "ops-bastion"

key_pair_file_bucket_name = "kg-tf-infra-ops"

## CIDR of ops VPC Subnet and VPN Client
allowed_cidr_blocks     = ["10.32.209.0/24", "10.32.208.0/24"]
vpn_allowed_cidr_blocks = ["10.200.0.0/16"]



