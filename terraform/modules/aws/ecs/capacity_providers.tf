###########################################
# Capacity Provider - Autoscaling Group(s)
###########################################

resource "aws_ecs_capacity_provider" "this" {
  for_each = { for k, v in var.capacity_providers : k => v if var.create_services }

  name = try(each.value.name, each.key)

  auto_scaling_group_provider {
    auto_scaling_group_arn         = each.value.auto_scaling_group_arn
    managed_termination_protection = length(try([each.value.managed_scaling], [])) == 0 ? "DISABLED" : try(each.value.managed_termination_protection, null)

    dynamic "managed_scaling" {
      for_each = try([each.value.managed_scaling], [])
      content {
        instance_warmup_period    = try(managed_scaling.value.instance_warmup_period, null)
        maximum_scaling_step_size = try(managed_scaling.value.maximum_scaling_step_size, null)
        minimum_scaling_step_size = try(managed_scaling.value.minimum_scaling_step_size, null)
        status                    = try(managed_scaling.value.status, null)
        target_capacity           = try(managed_scaling.value.target_capacity, null)
      }
    }
  }

  tags = merge(
    { "Name" = local.name_prefix },
    var.custom_tags
  )
}

##############################
# Cluster Capacity Providers
##############################

resource "aws_ecs_cluster_capacity_providers" "this" {
  count = var.create_cluster ? 1 : 0

  cluster_name = aws_ecs_cluster.main[0].name
  capacity_providers = distinct([
    for k, v in var.capacity_providers : try(v.name, k)
  ])

  dynamic "default_capacity_provider_strategy" {
    for_each = var.capacity_providers
    content {
      capacity_provider = try(default_capacity_provider_strategy.value.name, default_capacity_provider_strategy.key)
      base              = try(default_capacity_provider_strategy.value.default_capacity_provider_strategy.base, 0)
      weight            = try(default_capacity_provider_strategy.value.default_capacity_provider_strategy.weight, 100)
    }
  }

  # Ensure that the capacity providers are ACTIVE before applying the cluster update.
  depends_on = [
    aws_ecs_capacity_provider.this,
    time_sleep.wait_for_cp
  ]
  # lifecycle {
  #   create_before_destroy = true
  # }
}

#################################################
# Wait for each Capacity Provider to become ACTIVE
#################################################
resource "time_sleep" "wait_for_cp" {
  create_duration = "90s"
  depends_on      = [aws_ecs_capacity_provider.this]
}
