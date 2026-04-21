#-----------------------
# Step Scaling
#-----------------------

resource "aws_appautoscaling_policy" "scale_out" {
  count              = var.create_services && var.enable_autoscaling && var.use_step_scaling ? 1 : 0
  name               = "${local.name_prefix}-scale-out"
  service_namespace  = var.service_namespace
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = var.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_out_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = 0
      metric_interval_upper_bound = null
      scaling_adjustment          = 1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_appautoscaling_policy" "scale_in" {
  count              = var.create_services && var.enable_autoscaling && var.use_step_scaling ? 1 : 0
  name               = "${local.name_prefix}-scale-in"
  service_namespace  = var.service_namespace
  resource_id        = "service/${var.cluster_name}/${aws_ecs_service.main[0].name}"
  scalable_dimension = var.scalable_dimension
  policy_type        = "StepScaling"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = var.scale_in_cooldown
    metric_aggregation_type = "Average"

    step_adjustment {
      metric_interval_lower_bound = null
      metric_interval_upper_bound = 0
      scaling_adjustment          = -1
    }
  }

  depends_on = [aws_appautoscaling_target.ecs_target]
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count               = var.create_services && var.enable_autoscaling && var.use_step_scaling && var.enable_cpu_based_autoscaling ? 1 : 0
  alarm_name          = "${local.name_prefix}-cpu-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_out_period_seconds
  statistic           = "Average"
  threshold           = var.cpu_target_value

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main[0].name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out[0].arn]
  tags          = merge({ "Name" = "${local.name_prefix}-cpu-high" }, var.custom_tags)
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  count               = var.create_services && var.enable_autoscaling && var.use_step_scaling && var.enable_memory_based_autoscaling ? 1 : 0
  alarm_name          = "${local.name_prefix}-memory-utilization-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.scale_out_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_out_period_seconds
  statistic           = "Average"
  threshold           = var.memory_target_value

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main[0].name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_out[0].arn]
  tags          = merge({ "Name" = "${local.name_prefix}-memory-high" }, var.custom_tags)
}

resource "aws_cloudwatch_metric_alarm" "cpu_low" {
  count               = var.create_services && var.enable_autoscaling && var.use_step_scaling && var.enable_cpu_based_autoscaling ? 1 : 0
  alarm_name          = "${local.name_prefix}-cpu-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_in_period_seconds
  statistic           = "Average"
  threshold           = var.scale_in_cpu_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main[0].name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in[0].arn]
  tags          = merge({ "Name" = "${local.name_prefix}-cpu-low" }, var.custom_tags)
}

resource "aws_cloudwatch_metric_alarm" "memory_low" {
  count               = var.create_services && var.enable_autoscaling && var.use_step_scaling && var.enable_memory_based_autoscaling ? 1 : 0
  alarm_name          = "${local.name_prefix}-memory-utilization-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = var.scale_in_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.scale_in_period_seconds
  statistic           = "Average"
  threshold           = var.scale_in_memory_threshold

  dimensions = {
    ClusterName = var.cluster_name
    ServiceName = aws_ecs_service.main[0].name
  }

  alarm_actions = [aws_appautoscaling_policy.scale_in[0].arn]
  tags          = merge({ "Name" = "${local.name_prefix}-memory-low" }, var.custom_tags)
}
