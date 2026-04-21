#================================
# Global
#================================
variable "project_name" {
  description = "Name of the Project"
  type        = string
}

variable "environment" {
  description = "Environment of the project"
  default     = "test"
  type        = string
}

variable "availability_zones" {
  description = "The list of availability zones names or ids in the region."
  type        = list(string)
  default     = []
}

#================================
# VPC
#================================
variable "vpc_cidr_block" {
  description = "The IPv4 CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}



#================================
# Amazon ACM
#================================
# variable "create_acm_certificate" {
#   description = "Specify whether to create acm certificate or not."
#   default     = false
#   type        = bool
# }

# variable "domain_name" {
#   description = "Name of the root domain"
#   type        = string
# }

# variable "subject_alternative_names" {
#   description = "Set of domains that should be SANs in the issued certificate."
#   type        = list(string)
#   default     = null
# }

# variable "acm_validation_method" {
#   type        = string
#   default     = "DNS"
#   description = "Which method to use for validation. DNS or EMAIL are valid. This parameter must not be set for certificates that were imported into ACM and then into Terraform."
# }

#================================
# GitHub OIDC
#================================
variable "github_repo" {
  description = "GitHub repository name for backend"
  type        = string
  default     = ""
}
