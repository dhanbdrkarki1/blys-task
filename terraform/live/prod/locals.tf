locals {
  # AWS Account and Region Information
  account_id = data.aws_caller_identity.current.account_id # Current AWS account ID
  aws_region = data.aws_region.current.id                  # Current AWS region

  domain_name = "*.karkidhan.com.np"

  ###########################
  # ECR Repositories
  ###########################
  repository_names = [
    "blyss-be"
  ]

  ###########################
  # Secrets
  ###########################
  # Secrets Manager
  app_secrets_manager = {
    AUTH0_SECRET = {
      name        = "${var.project_name}/${var.environment}/blyss-be/AUTH0_SECRET"
      description = "Auth0 secret for backend API"
    }
  }

  # Parameter store
  app_ssm_parameters = {
    API_SECRET_KEY = {
      path        = "/${var.project_name}/${var.environment}/blyss-be/API_SECRET_KEY"
      description = "API secret key"
      value       = "CHANGE_ME"
    }
  }

  ###########################
  # Application Load Balancer (ALB)
  ###########################

  # Target Groups for ALB
  alb_target_groups = {
    # blyss BE
    blyss-be = {
      name                 = "blyss-be-tg" # Name of the target group
      protocol             = "HTTP"        # Protocol for the target group
      port                 = 8000          # Port for the target group
      target_type          = "ip"          # Target type (instance or IP)
      deregistration_delay = 10            # Time to wait before deregistering targets

      # Health Check Configuration
      health_check = {
        enabled             = true               # Enable health checks
        interval            = 60                 # Health check interval in seconds
        path                = "/api/health/live" # Health check path
        port                = "traffic-port"     # Use the same port as the application
        healthy_threshold   = 2                  # Consecutive successes to mark as healthy
        unhealthy_threshold = 2                  # Consecutive failures to mark as unhealthy
        timeout             = 5                  # Health check timeout in seconds
        protocol            = "HTTP"             # Health check protocol
        matcher             = "200-399"          # HTTP response codes considered healthy
      }
    }
  }

  # ALB Listeners
  alb_listeners = {
    ## Redirect HTTP to HTTPS
    http-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
      conditions = [{
        host_header = {
          values = ["api.karkidhan.com.np"]
        }
      }]
    }
    # HTTPS Listener for backend API
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS13-1-2-2021-06"
      certificate_arn = data.aws_acm_certificate.amazon_issued.arn
      fixed_response = {
        content_type = "text/plain"
        message_body = "404: page not found"
        status_code  = "404"
      }
      rules = {
        blyss-be = {
          priority = 100
          actions = [
            {
              type             = "forward"
              target_group_arn = try(module.alb.target_group_arns["blyss-be"], null)
            }
          ]
          conditions = [{
            host_header = {
              values = ["api.karkidhan.com.np"]
            }
          }]
        }
      }
    }
  }

  ###########################
  # CloudWatch Log Groups
  ###########################
  log_groups = {
    # Log group for ECS API service
    blyss-be-api = {
      name              = "/ecs/service/blyss-be" # Log group name
      retention_in_days = 30                      # Log retention period in days
    }
  }

  ecs_services = {
    # blyss BE API
    blyss-be-api = {
      desired_count = 2      # Desired number of tasks
      cpu           = "512"  # CPU units for Fargate (0.5 vCPU) - must be string
      memory        = "1024" # Memory in MB for Fargate (1 GB) - must be string

      # Auto Scaling (CPU-only target tracking; avoids CPU+memory fighting)
      enable_autoscaling              = true
      min_capacity                    = 1
      max_capacity                    = 4
      enable_cpu_based_autoscaling    = true
      enable_memory_based_autoscaling = false
      cpu_target_value                = 70
      scale_in_cooldown               = 300   # Seconds to wait after scale-in before scaling again
      scale_out_cooldown              = 60    # Seconds to wait after scale-out before scaling again
      use_step_scaling                = false # true = step scaling (custom alarms); false = target tracking
      scale_out_evaluation_periods    = 3     # Datapoints for scale-out alarm (e.g. 3 = 3 min with 60s period)
      scale_in_evaluation_periods     = 15    # Datapoints for scale-in alarm (e.g. 15 = 15 min)
      scale_in_cpu_threshold          = 40    # Scale-in when CPU <= 40% (step scaling only)
      scale_in_memory_threshold       = 40    # Scale-in when memory <= 40% (step scaling only)

      # Container Definition
      container_definitions = [
        {
          name              = "blyss-be"                                        # Container name
          cpu               = 512                                               # CPU units for the container (Fargate)
          memory            = 1024                                              # Memory in MB for the container (Fargate)
          memoryReservation = 768                                               # Memory reservation to prevent OOM kills
          essential         = true                                              # Mark container as essential
          image             = "${module.ecr["blyss-be"].repository_url}:latest" # Container image from ECR
          # enables the init process inside the container
          linuxParameters = {
            initProcessEnabled = true
          }
          portMappings = [
            {
              name          = "blyss-be" # Port name
              containerPort = 8000       # Container port
              protocol      = "tcp"      # Protocol (TCP)
              appProtocol   = "http"     # Application protocol (HTTP)
            }
          ]
          readonlyRootFilesystem = false # Allow writing to the root filesystem

          # Container health check
          healthCheck = {
            command     = ["CMD-SHELL", "curl -f http://localhost:8000/api/health/live || exit 1"]
            interval    = 30
            timeout     = 5
            retries     = 3
            startPeriod = 60
          }

          secrets = [
            {
              name      = "API_SECRET_KEY"
              valueFrom = module.app_parameters.parameter_arns["API_SECRET_KEY"]
            },
            {
              name      = "AUTH0_SECRET"
              valueFrom = module.app_secrets["AUTH0_SECRET"].secret_arn
            }
          ]

          logConfiguration = {
            logDriver = "awslogs" # Log driver (CloudWatch Logs)
            options = {
              "awslogs-group"         = module.cloudwatch_log_groups["blyss-be-api"].log_group_name # Log group name
              "awslogs-region"        = data.aws_region.current.id                                  # AWS region
              "awslogs-stream-prefix" = "blyss-be"                                                  # Log stream prefix
            }
          }
        }
      ]
      container_name            = "blyss-be" # Name of the container
      container_port            = 8000       # Port exposed by the container
      target_group              = "blyss-be" # Target group for the service
      attach_to_alb             = true
      health_check_grace_period = 60
      # No capacity_provider needed - using Fargate
      # service connect configuration
      service_connect_configuration = {
        enabled   = true
        namespace = module.cloudmap.namespace_arn # CloudMap namespace ID
        service = {
          port_name      = "blyss-be" # must match name in container definition
          discovery_name = "blyss-be"
          client_alias = {
            port     = 8000
            dns_name = "blyss-be"
          }
        }
        log_configuration = {
          log_driver = "awslogs"
          options = {
            "awslogs-group"         = "/ecs/service-connect/blyss-be"
            "awslogs-region"        = data.aws_region.current.id
            "awslogs-stream-prefix" = "service-connect"
            "awslogs-create-group"  = "true"
          }
        }
      }
    }
  }


}
