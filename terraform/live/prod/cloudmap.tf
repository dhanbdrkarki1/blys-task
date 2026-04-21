
# For Private DNS namespace
# Note: enables DNS-based service discovery, making it possible for your services to communicate using names.
module "cloudmap" {
  source = "../../modules/aws/cloudmap"

  create_private_dns_namespace = true
  namespace_name               = var.project_name
  vpc_id                       = module.vpc.vpc_id
  description                  = "Private DNS namespace for ${var.project_name}"

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "network"
  }
}
