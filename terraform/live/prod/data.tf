# Get current AWS region
data "aws_region" "current" {}

# data "aws_partition" "current" {}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Find a certificate issued by (not imported into) ACM
data "aws_acm_certificate" "amazon_issued" {
  domain      = local.domain_name
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
