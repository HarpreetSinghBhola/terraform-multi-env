azs = ["us-east-1a", "us-east-1b"]
private_subnets = ["10.32.214.0/24", "10.32.215.0/24"]
#Used as the prefix to define the name of the subnet
name = "qa-kyckg"
contact_name = "kg-devops"

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"