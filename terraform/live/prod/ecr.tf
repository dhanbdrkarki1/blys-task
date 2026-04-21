module "ecr" {
  source = "../../modules/aws/ecr"

  for_each = toset(local.repository_names)

  create             = true
  name               = each.value
  image_immutability = "MUTABLE" # Setting value to "MUTABLE" allowS to override image.
  force_delete       = false     # If true, will delete the repository even if it contains images.

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Repository  = each.value
    Purpose     = "storage"
  }
}
