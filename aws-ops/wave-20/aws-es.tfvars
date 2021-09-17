
contact_name = "kg-devops"

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"


advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

es_domain_name = "es-ops"

## CIDR of ops VPC Subnet and VPN Client
allowed_cidr_blocks     = ["10.32.209.0/24", "10.32.208.0/24"]
vpn_allowed_cidr_blocks = ["10.200.0.0/16"]

## Allow SGs to Access ES
security_groups = ["sg-0b5834469fd9b39ad"]

## Enable the ES
enabled = true

elasticsearch_version = "7.10"
instance_type = "t2.small.elasticsearch"
instance_count = 2

dedicated_master_enabled = false
dedicated_master_count   = 0 
dedicated_master_type    = "t2.small.elasticsearch"

iam_actions              = ["*"]
iam_role_arns            = []

## EBS volumes for data storage in GB
ebs_volume_size = 10
ebs_volume_type = "gp2"

encrypt_at_rest_enabled = false

## Days of retention of cloudwatch.
logs_retention = 30 


