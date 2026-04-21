#================================
# Amazon VPC
#================================
module "vpc" {
  source = "../../modules/aws/vpc"
  create = true

  name                       = "vpc"
  availability_zones         = var.availability_zones
  cidr_block                 = var.vpc_cidr_block
  public_subnet_cidr_blocks  = var.public_subnet_cidr_blocks
  private_subnet_cidr_blocks = var.private_subnet_cidr_blocks

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_nat_gateway     = true
  one_nat_gateway_per_az = true
  single_nat_gateway     = false

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "network"
  }
}
