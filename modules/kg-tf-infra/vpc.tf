# Provision NAT EIPs ourside of the VPC so they are not managed by the VPC module
# resource "aws_eip" "nat" {
#   count = 3
#   vpc = true
# }

# Provision VPC
module "vpc" {
  source = "../vpc"
  
  cidr                 = var.vpc_cidr
  azs                  = var.vpc_azs
  private_subnets      = var.private_subnets
  public_subnets       = var.public_subnets
  enable_nat_gateway   = true
  name                 = var.name
  tags = {
    Environment =  var.environment_name
    Contact     =  var.contact_name
    Product     =  var.product_name
    Terraform   = "true"
  }
}
