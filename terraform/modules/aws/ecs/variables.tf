#########
# ECS
#########
variable "create_cluster" {
  default     = false
  type        = bool
  description = "Specify whether to create ECS cluster or not"
}

variable "create_services" {
  default     = false
  type        = bool
  description = "Specify whether to create ECS service or not"
}

variable "name" {
  description = "Name to be used on ECS cluster created"
  type        = string
  default     = ""
}

##############
# Cluster
##############
variable "cluster_id" {
  description = "The ID of the ECS Cluster"
  default     = null
  type        = string
}

variable "cluster_name" {
  description = "The Name of the ECS Cluster"
  default     = null
  type        = string
}

variable "cluster_configuration" {
  description = "The execute command configuration for the cluster"
  type        = any
  default     = {}
}

variable "cluster_settings" {
  description = <<-DOC
    List of configuration block(s) with cluster settings. For example, this can be used to enable CloudWatch Container Insights for a cluster.
    Valid values: enhanced, enabled, disabled.
    - enhanced: Provides detailed health and performance metrics at the task and container level, in addition to aggregated metrics at the cluster and service level. Enables easier drill downs for faster problem isolation and troubleshooting.
    - enabled: Provides aggregated metrics at the cluster and service level.
    - disabled: Disables all metrics collection.
  DOC

  type = any

  default = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]
}


variable "cluster_service_connect_defaults" {
  description = "Configures a default Service Connect namespace"
  type        = map(string)
  default     = {}
}

##############
# Service
##############
variable "enable_ecs_managed_tags" {
  description = "Specifies whether to enable Amazon ECS managed tags for the tasks within the service"
  type        = bool
  default     = false
}

variable "enable_execute_command" {
  description = "Specifies whether to enable Amazon ECS Exec for the tasks within the service"
  type        = bool
  default     = false
}

variable "service_connect_configuration" {
  description = "The ECS Service Connect configuration for this service to discover and connect to services, and be discovered by, and connected from, other services within a namespace"
  type        = any
  default     = {}
}

####################
# Task Definition
#####################
variable "network_mode" {
  description = "Docker networking mode to use for the containers in the task. Valid values are `none`, `bridge`, `awsvpc`, and `host`"
  type        = string
  default     = "awsvpc"
}

variable "requires_compatibilities" {
  description = "Set of launch types required by the task. The valid values are `EC2` and `FARGATE`"
  type        = list(string)
  default     = ["FARGATE"]
}

variable "runtime_platform" {
  description = "Configuration block for `runtime_platform` that containers in your task may use"
  type        = any
  default = {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
}

#---------------------------
# Container Task Definition
#---------------------------
variable "cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  type        = string
  default     = "256"
}

variable "memory" {
  description = "Fargate instance memory to provision (in MiB)"
  type        = string
  default     = "512"
}

variable "desired_count" {
  description = "Number of instances of the task definition to place and keep running."
  type        = number
  default     = 2
}


variable "container_definitions" {
  description = "A map of container definitions for the ECS service"
  type        = any
  default     = {}
}




variable "deployment_circuit_breaker" {
  description = "Configuration block for deployment circuit breaker"
  type        = any
  default     = {}
}

variable "deployment_controller" {
  description = <<-DOC
    Configuration block for deployment controller configuration.
    type - (Optional) Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL. Default: ECS.
  DOC
  type        = any
  default     = {}
}


variable "load_balancer" {
  description = "Configuration block for load balancers"
  type        = any
  default     = {}
}

# variable "deployment_controller_type" {
#   type        = string
#   default     = "ECS"
#   description = "Type of deployment controller. Valid values: CODE_DEPLOY, ECS, EXTERNAL"
# }

# variable "enable_deployment_circuit_breaker" {
#   description = "Whether to enable the deployment circuit breaker logic for the service."
#   default     = false
#   type        = bool
# }

# variable "enable_deployment_circuit_breaker_rollback" {
#   description = "Whether to enable Amazon ECS to roll back the service if a service deployment fails. If rollback is enabled, when a service deployment fails, the service is rolled back to the last deployment that completed successfully."
#   default     = false
#   type        = bool
# }














# Network Configuration
variable "network_configuration" {
  description = "Network configuration for the ECS service"
  type = object({
    subnets          = list(string)
    assign_public_ip = bool
    security_groups  = list(string)
  })
  default = {
    subnets          = []
    assign_public_ip = false
    security_groups  = []
  }
}


# variable "security_groups_ids" {
#   description = "A list of security group IDs to assign to the ECS Task"
#   type        = list(string)
#   default     = []
# }

# variable "subnet_groups_ids" {
#   description = "A list of subnet group IDs to assign to the ECS Task"
#   type        = list(string)
#   default     = []
# }

# variable "assign_public_ip" {
#   description = "Assign a public IP address to the ENI (Fargate launch type only)"
#   type        = bool
#   default     = false
# }


variable "ecs_task_family_name" {
  description = "The name of the family on ECS task definition."
  type        = string
  default     = ""
}
variable "health_check_grace_period" {
  description = "Seconds to ignore failing load balancer health checks on newly instantiated tasks to prevent premature shutdown"
  type        = number
  default     = 300
}

#######################
# Cluster and Capacity Providers
#######################
variable "capacity_provider_strategy" {
  description = "Capacity provider strategies to use for the service. Can be one or more"
  type        = any
  default     = {}
}

variable "default_capacity_provider_use_fargate" {
  description = "Determines whether to use Fargate or autoscaling for default capacity provider strategy"
  type        = bool
  default     = true
}

variable "capacity_providers" {
  description = "Map of autoscaling capacity provider definitions to create for the cluster"
  type        = any
  default     = {}
}

# Auto Scaling
variable "enable_autoscaling" {
  description = "Enable auto scaling for the ECS service"
  type        = bool
  default     = false
}

variable "service_namespace" {
  type        = string
  default     = "ecs"
  description = "AWS service namespace of the scalable target."
}

variable "scalable_dimension" {
  type        = string
  default     = "ecs:service:DesiredCount"
  description = "Scalable dimension of the scalable target."
}

variable "min_capacity" {
  description = "Minimum capacity of the scalable target of ECS"
  type        = number
  default     = 1
}

variable "max_capacity" {
  description = "Maximum capacity of the scalable target of ECS"
  type        = number
  default     = 4
}

# Target Tracking Scaling
variable "enable_cpu_based_autoscaling" {
  description = "Enable CPU-based auto scaling"
  type        = bool
  default     = false
}

variable "enable_memory_based_autoscaling" {
  description = "Enable memory-based auto scaling"
  type        = bool
  default     = false
}

variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 70
}

variable "memory_target_value" {
  description = "Target memory utilization percentage for auto scaling"
  type        = number
  default     = 80
}

variable "scale_in_cooldown" {
  description = "Amount of time, in seconds, after a scale-in activity completes before another scale-in can start"
  type        = number
  default     = 300
}

variable "scale_out_cooldown" {
  description = "Amount of time, in seconds, after a scale-out activity completes before another scale-out can start"
  type        = number
  default     = 60
}

# Step Scaling (alternative to target tracking: custom alarms, scale-in when both CPU & memory low)
variable "use_step_scaling" {
  description = "Use step scaling with custom CloudWatch alarms instead of target tracking. Scale-out: 3 datapoints/3 min; scale-in: 15 datapoints/15 min (only when both CPU and memory below thresholds)."
  type        = bool
  default     = false
}

variable "scale_out_evaluation_periods" {
  description = "Number of periods for scale-out alarm (e.g. 3 = 3 min with 60s period)"
  type        = number
  default     = 3
}

variable "scale_out_period_seconds" {
  description = "Period in seconds for scale-out alarm"
  type        = number
  default     = 60
}

variable "scale_in_evaluation_periods" {
  description = "Number of periods for scale-in alarm (e.g. 15 = 15 min with 60s period)"
  type        = number
  default     = 15
}

variable "scale_in_period_seconds" {
  description = "Period in seconds for scale-in alarm"
  type        = number
  default     = 60
}

variable "scale_in_cpu_threshold" {
  description = "CPU utilization % below which scale-in alarm fires (scale in when both CPU and memory below thresholds)"
  type        = number
  default     = 40
}

variable "scale_in_memory_threshold" {
  description = "Memory utilization % below which scale-in alarm fires"
  type        = number
  default     = 40
}

# IAM Role
variable "ecs_task_execution_role" {
  description = "ARN of the IAM role that allows Amazon ECS to make calls to other AWS services."
  type        = string
  default     = null
}

variable "ecs_task_role" {
  description = "ARN of the task role that the Amazon ECS container agent and the Docker daemon can assume"
  type        = string
  default     = null
}

# EFS
variable "mount_efs_volume" {
  type        = bool
  default     = false
  description = "Specify whether to mount EFS volume in the ECS container or not."
}

variable "efs_file_system_id" {
  type        = string
  description = "The id of the EFS file system"
  default     = null

}

variable "volume_root_directory" {
  type        = string
  description = "The root directory of the EFS file system to be attached with ECS task."
  default     = "/"
}

variable "enable_transit_encryption" {
  type        = string
  description = "Whether or not to enable encryption for Amazon EFS data in transit between the Amazon ECS host and the Amazon EFS server. "
  default     = "ENABLED"
}

variable "transit_encryption_port" {
  type        = number
  description = "Port to use for transit encryption in Amazon EFS"
  default     = 2049
}

# Service
variable "scheduling_strategy" {
  description = "Scheduling strategy to use for the service. The valid values are `REPLICA` and `DAEMON`. Defaults to `REPLICA`"
  type        = string
  default     = "REPLICA"
}


# variable "source_volume" {
#   type = string
#   default = null
#   description = "The name of the volume to mount. Must be a volume name referenced in the name parameter of task definition volume"
# }



# Tags
variable "ecs_tags" {
  description = "Tags to set on the ECS."
  type        = map(string)
  default     = {}
}

variable "custom_tags" {
  description = "Custom tags to set on all the resources."
  type        = map(string)
  default     = {}
}
