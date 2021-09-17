module "infra" {
  source              = "../kg-tf-infra"
 
  region              = var.region
  environment_name    = var.environment_name
  product_name        = var.product_name
  contact_name        = var.contact_name
  vpc_cidr            = var.vpc_cidr
  vpc_azs             = var.vpc_azs
  private_subnets     = var.private_subnets
  public_subnets      = var.public_subnets
  name                = var.name
  private_subnet_tags = {
    "Tier" = "Private"

  }
  public_subnet_tags = {
    "Tier" = "Public"

  }
}
