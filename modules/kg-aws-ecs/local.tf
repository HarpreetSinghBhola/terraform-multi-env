#Common Tags
locals {
  tags = {
    Environment =  var.environment_name
    Contact     =  var.contact_name
    Product     =  var.product_name
    Terraform   = "true"
  }

}