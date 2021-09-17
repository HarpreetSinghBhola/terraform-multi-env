
#Used as the prefix to define the name of the subnet
name_prefix = "ops-kyckg"

contact_name = "kg-devops"

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"

redis_clusters = 1
redis_node_type = "cache.m3.medium"
redis_version = "6.x"

#Used for creating the name of the resources
name = "kyckg-redis"


redis_maintenance_window = "fri:08:00-fri:09:00"
redis_snapshot_window = "06:30-07:30"
redis_snapshot_retention_limit = "0"
redis_failover = false
multi_az_enabled = false
availability_zones = []

at_rest_encryption_enabled = "true"
transit_encryption_enabled = "true"

#A list CIDRs to allow access to.
allowed_cidr = ["10.200.0.0/16", "10.32.208.0/20"]

#"List of VPC Subnet IDs for the cache subnet group"
subnets = ["subnet-0c959567c8e0e428f", "subnet-09f36a8517c46c99b"]
