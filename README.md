### Introduction

This Repo will be used to run the Terraform modules against AWS. Jenkins is configured to deploy the resources on AWS using this repo.


#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.26 |

#### File and Folder Details:

* `Jenkinsfile`: Jenkins used this file to run the Job.
* `run.sh`: This file is used to run the TF wrt input in passed `Jenkinsfile`
* `aws-<env>`: This folder contains the following:
    * `backend.tfvars`: TF backend details
    * `shared.tfvars`: common things which is common irrespective of wave and same at environment level.
    * `wave-*`: segeration of AWS resources based on its priority.
        * `<resource_name>.module`: which resource have to called from modules folder
        * `<resource_name>.tfvars`: Terraform variable file
* `modules`: This folder contains the AWS resources's tf code that will be common to every environment. And can be called from `wave-*/<resource_name>.module`
* `aws-shared-*`: This folder is used to do the base setup for environments. 

## Modules
Below are the modules that which is used by TF to deploy the resources on AWS.
```
modules/
├── kg-aws-bastion
│   ├── README.md
│   ├── backend.tf
│   ├── local.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── kg-aws-vpn
│   ├── README.md
│   ├── backend.tf
│   ├── local.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── scripts
│   ├── variables.tf
│   └── versions.tf
├── kg-setup
│   ├── README.md
│   ├── backend.tf
│   ├── local.tf
│   ├── main.tf
│   ├── output.tf
│   ├── provider.tf
│   └── variables.tf
└── kg-subnets
    ├── README.md
    ├── backend.tf
    ├── local.tf
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    └── variables.tf
```
