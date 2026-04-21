
locals {
  name_prefix = "${var.custom_tags["Project"] != "" ? var.custom_tags["Project"] : "default-project"}-${var.custom_tags["Environment"] != "" ? var.custom_tags["Environment"] : "default-env"}-${var.name != "" ? var.name : "default-name"}"

  # for efs volume
  source_volume_name = var.mount_efs_volume ? "${var.name != "" ? var.name : "default-name"}-efs-volume" : null

  ecs_capacity_provider_names = var.default_capacity_provider_use_fargate ? [
    for k, v in var.capacity_provider_strategy : v.capacity_provider
  ] : [for k, v in aws_ecs_capacity_provider.this : v.name]

}
