#################################
# Elastic Container Registry
#################################

locals {
  name_prefix = lower(
    join("-",
      compact([
        lookup(var.custom_tags, "Project", "default"),
        lookup(var.custom_tags, "Environment", "default"),
        var.name
      ])
    )
  )
}

resource "aws_ecr_repository" "ecr" {
  count                = var.create ? 1 : 0
  name                 = local.name_prefix
  image_tag_mutability = var.image_immutability
  force_delete         = var.force_delete
  encryption_configuration {
    encryption_type = var.encryption_type
  }
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = merge(
    { "Name" = local.name_prefix },
    var.ecr_tags,
    var.custom_tags
  )
}
