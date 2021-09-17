# Environment Terraform Module

This module is used to create an environment base for middleware and applications. It created the following:
- infrastructure: VPC

It is using other TF modules to provision the resources.

## Outputs
Most outputs of modules used here are used as outputs of this module. This includes VPC information, security group IDs, Route53 info, IAM ssh group name.

## Module configuration
See [variables.tf](variables.tf) for a list of all module variables and description.
