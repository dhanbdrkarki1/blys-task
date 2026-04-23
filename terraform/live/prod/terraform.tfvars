#================================
# Global
#================================
project_name       = "blyss"
availability_zones = ["us-east-1a", "us-east-1b"]
environment        = "prod"


#================================
# VPC
#================================
vpc_cidr_block             = "10.50.0.0/16"
public_subnet_cidr_blocks  = ["10.50.0.0/23", "10.50.2.0/23"]
private_subnet_cidr_blocks = ["10.50.4.0/23", "10.50.6.0/23"]

#================================
# GitHub OIDC
#================================
github_repo = "dhanbdrkarki1/blys-task"
