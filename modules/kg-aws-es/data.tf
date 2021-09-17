# Remote TF_State Details to fetch VPC Details

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = var.state_bucket_name_vpc
    key    = "infra.tfstate"
    region = var.region
  }
}