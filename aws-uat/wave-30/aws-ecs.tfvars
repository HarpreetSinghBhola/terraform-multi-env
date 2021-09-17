contact_name = "kg-devops"

######## Remote s3 state file details for fetching VPC details "terraform_remote_state", used in launching resources
state_bucket_name_vpc = "kg-tf-infra-ops"

##At end Cluster name will be <environment_name>-<cluster_name>
cluster_name = "kyckg-fargate"

##Specifies whether to enable Amazon ECS Exec for the tasks within the service.
enable_execute_command = true