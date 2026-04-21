terraform {
  required_version = "~> 1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
  backend "s3" {
    key          = "prod/services/terraform.tfstate"
    region       = "us-east-1"
    bucket       = "dbk-terraform-state-bs"
    use_lockfile = true
    encrypt      = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"

  # Tags to apply to all AWS resources by default
  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Team      = "DevOps"
    }
  }
}
