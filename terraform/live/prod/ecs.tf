#================================
# ECS Cluster
#================================
module "ecs_cluster" {
  source         = "../../modules/aws/ecs"
  create_cluster = true
  name           = "ecs"

  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  # created using cloudmap module
  cluster_service_connect_defaults = {
    namespace = module.cloudmap.namespace_arn
  }

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "compute"
  }
}

#================================
# ECS Services
#================================
module "ecs_services" {
  source          = "../../modules/aws/ecs"
  for_each        = local.ecs_services
  create_services = true
  name            = each.key

  cluster_id   = module.ecs_cluster.cluster_id
  cluster_name = module.ecs_cluster.cluster_name

  # Container Definition (JSON-encoded)
  container_definitions = jsonencode(each.value.container_definitions)

  # Disable ECS Exec
  enable_execute_command = false

  # Task Definition
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  ecs_task_family_name     = "${var.project_name}-${var.environment}-${each.key}-task"
  ecs_task_execution_role  = try(module.ecs_task_execution_role.role_arn, null)
  ecs_task_role            = try(module.ecs_task_role.role_arn, null)
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  runtime_platform = {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }

  # # Network Configuration (required for network_mode set to awsvpc)
  network_configuration = {
    subnets          = module.vpc.private_subnet_ids
    assign_public_ip = false
    security_groups = [
      module.ecs_sg.security_group_id
    ]
  }

  # ECS Service
  desired_count             = each.value.desired_count
  scheduling_strategy       = "REPLICA"
  health_check_grace_period = try(each.value.health_check_grace_period, null)

  # Load Balancer
  load_balancer = try(each.value.attach_to_alb, false) ? {
    service = {
      target_group_arn = module.alb.target_group_arns[each.value.target_group]
      container_name   = each.value.container_name
      container_port   = each.value.container_port
    }
  } : {}

  # Capacity provider configuration for Fargate
  capacity_provider_strategy = {
    fargate = {
      capacity_provider = "FARGATE"
      weight            = 1
      base              = 1
    }
  }

  # Use Fargate capacity provider
  default_capacity_provider_use_fargate = true
  capacity_providers                    = {}

  # Auto Scaling
  enable_autoscaling              = try(each.value.enable_autoscaling, false)
  min_capacity                    = try(each.value.min_capacity, 1)
  max_capacity                    = try(each.value.max_capacity, 4)
  enable_cpu_based_autoscaling    = try(each.value.enable_cpu_based_autoscaling, true)
  enable_memory_based_autoscaling = try(each.value.enable_memory_based_autoscaling, true)
  cpu_target_value                = try(each.value.cpu_target_value, 70)
  memory_target_value             = try(each.value.memory_target_value, 80)
  scale_in_cooldown               = try(each.value.scale_in_cooldown, 300)
  scale_out_cooldown              = try(each.value.scale_out_cooldown, 60)
  use_step_scaling                = try(each.value.use_step_scaling, false)
  scale_out_evaluation_periods    = try(each.value.scale_out_evaluation_periods, 3)
  scale_out_period_seconds        = try(each.value.scale_out_period_seconds, 60)
  scale_in_evaluation_periods     = try(each.value.scale_in_evaluation_periods, 15)
  scale_in_period_seconds         = try(each.value.scale_in_period_seconds, 60)
  scale_in_cpu_threshold          = try(each.value.scale_in_cpu_threshold, 40)
  scale_in_memory_threshold       = try(each.value.scale_in_memory_threshold, 40)

  # service connect configuration
  service_connect_configuration = each.value.service_connect_configuration

  # # Deployment Circuit Breaker (only supported with ECS (rolling update) deployment controller)
  deployment_circuit_breaker = {
    enable   = true
    rollback = true
  }

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Service     = each.key
    Purpose     = "compute"
  }
}
