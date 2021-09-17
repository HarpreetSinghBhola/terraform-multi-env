#### This module will be used to setup the S3 and create DynamoDB table for enabling tfstate file locking.
### S3 bucket that will be used as backent for the kyckglobal environments


########################################################################################

## NAME OF THE S3 BUCKKETS THAT WILL BE CREATED BY THE MODULES

# S3 BUCKET NAME AS PER ENVIRONMENTS
# bucket_name_dev = kg-tf-infra-dev
# bucket_name_uat = kg-tf-infra-uat
# bucket_name_staging = kg-tf-infra-staging
# bucket_name_sandbox = kg-tf-infra-sandbox

########################################################################################


###If you want to add new S3 Bucket add in same format, in below.
##kg-tf-infra-<env_name>

s3_bucket_backend_name = ["kg-tf-infra-ops", "kg-tf-infra-dev", "kg-tf-infra-uat", "kg-tf-infra-staging", "kg-tf-infra-sandbox"]
enable_versioning = true
encryption_sse_algorithm = "AES256"


#### DynamoDB for locking with Terraform

table_name = "terraform-up-and-running-locks"
hash_key   = "LockID"