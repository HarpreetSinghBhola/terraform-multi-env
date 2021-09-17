
#Used as the prefix to define the name of the subnet
vpn_name = "ops-kyckg-vpn"

contact_name = "kg-devops"
logs_retention = 30

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"

ovpn_file_bucket_name = "kg-tf-infra-ops"

client_cidr_block = "10.200.0.0/16"
client_auth = "certificate-authentication"
subnet_ids = ["subnet-0c959567c8e0e428f", "subnet-09f36a8517c46c99b"]
target_cidr_block = "10.32.208.0/20"
cloudwatch_log_stream = "ops-kyckg-client-vpn-log-stream"

#A list of client certificate name
clients = ["client"]