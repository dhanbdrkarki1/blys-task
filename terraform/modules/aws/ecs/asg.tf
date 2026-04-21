#-----------------------
# ECS Auto Scaling
#-----------------------

resource "aws_appautoscaling_target" "ecs_target" {
  count              = var.create_services && var.enable_autoscaling ? 1 : 0
  service_namespace  = var.service_namespace
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = var.scalable_dimension
  min_capacity       = var.min_capacity
  max_capacity       = var.max_capacity

  tags = merge(
    { "Name" = local.name_prefix },
    var.custom_tags
  )
}

# Target Tracking Scaling Policy - CPU
resource "aws_appautoscaling_policy" "ecs_policy_cpu" {
  count              = var.create_services && var.enable_autoscaling && !var.use_step_scaling && var.enable_cpu_based_autoscaling ? 1 : 0
  name               = "${local.name_prefix}-cpu-autoscaling"
  service_namespace  = var.service_namespace
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = var.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = var.cpu_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

# Target Tracking Scaling Policy - Memory
resource "aws_appautoscaling_policy" "ecs_policy_memory" {
  count              = var.create_services && var.enable_autoscaling && !var.use_step_scaling && var.enable_memory_based_autoscaling ? 1 : 0
  name               = "${local.name_prefix}-memory-autoscaling"
  service_namespace  = var.service_namespace
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = var.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    target_value       = var.memory_target_value
    scale_in_cooldown  = var.scale_in_cooldown
    scale_out_cooldown = var.scale_out_cooldown

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}
