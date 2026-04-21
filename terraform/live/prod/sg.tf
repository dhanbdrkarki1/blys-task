#================================
# ALB Security Groups
#================================
module "alb_sg" {
  source              = "../../modules/aws/sg"
  create              = true
  name                = "alb-sg"
  description         = "Security group for ALB."
  vpc_id              = module.vpc.vpc_id
  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp", "https-443-tcp"]
  egress_with_source_security_group_id = [
    {
      description              = "Allow ALB egress to ECS tasks on application port"
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      source_security_group_id = module.ecs_sg.security_group_id
    }
  ]
  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "security-group"
  }
}

#================================
# ECS Tasks Security Groups
#================================
module "ecs_sg" {
  source      = "../../modules/aws/sg"
  create      = true
  name        = "ecs-sg"
  description = "Security group for ECS tasks with Service Connect."
  vpc_id      = module.vpc.vpc_id
  ingress_with_source_security_group_id = [
    {
      description              = "Allow custom (port 8000) traffic from ALB"
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      description              = "Allow Service Connect traffic between ECS tasks on port 8000"
      from_port                = 8000
      to_port                  = 8000
      protocol                 = "tcp"
      source_security_group_id = module.ecs_sg.security_group_id
    }
  ]
  egress_with_cidr_blocks = [
    {
      description = "Allow HTTPS egress for AWS APIs and external integrations"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "security-group"
  }
}
