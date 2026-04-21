#================================
# ECS Task Execution Role and Policy
#================================
module "ecs_task_execution_role" {
  source           = "../../modules/aws/iam"
  create           = true
  role_name        = "TaskExectionRole"
  role_description = "IAM role for ECS Task"

  # Trust relationship policy for ECS Task
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  # ECS permissions policy
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CloudWatchLogsPermissions"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRAuthorizationToken"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRRepositoryAccess"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          module.ecr["blyss-be"].arn
        ]
      },
      {
        Sid    = "ParameterStoreAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters",
          "ssm:GetParameter"
        ]
        Resource = [
          module.app_parameters.parameter_arns["API_SECRET_KEY"],
        ]
      },
      {
        Sid    = "SecretsManagerAccess"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          module.app_secrets["AUTH0_SECRET"].secret_arn,
        ]
      }
    ]
  })

  role_policies = {}

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "security"
  }
}

#================================
# ECS Task Role
#================================
module "ecs_task_role" {
  source           = "../../modules/aws/iam"
  create           = true
  role_name        = "TaskRole"
  role_description = "IAM role for ECS Task"

  # Trust relationship policy for ECS Task
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  role_policies = {}

  policy_document = null



  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "iam-role"
  }
}

#================================
# GitHub OIDC Provider & Role for CI/CD
#================================
module "github_oidc_role" {
  source = "../../modules/aws/iam"

  create               = true
  create_oidc_provider = true
  role_name            = "GitHubOIDC"
  role_description     = "GitHub Actions OIDC role for ECS"

  # OIDC Provider Configuration
  oidc_provider_url = "https://token.actions.githubusercontent.com"
  oidc_client_id_list = [
    "sts.amazonaws.com"
  ]
  oidc_thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  # Role Trust Policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "arn:aws:iam::${local.account_id}:oidc-provider/token.actions.githubusercontent.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:${var.github_repo}:*",
            ]
          }
        }
      }
    ]
  })

  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ---------- ECR ----------
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = [
          module.ecr["blyss-be"].arn
        ]
      },

      # ---------- ECS Task Definition ----------
      {
        Sid    = "ECSTaskDefinitionDeploy"
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeTaskDefinition"
        ]
        Resource = [
          "arn:aws:ecs:${local.aws_region}:${local.account_id}:task-definition/${var.project_name}-${var.environment}-blyss-be-api-task*"
        ]
      },

      # ---------- ECS Service ----------
      {
        Sid    = "ECSServiceDeploy"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices"
        ]
        Resource = [
          "arn:aws:ecs:${local.aws_region}:${local.account_id}:service/${module.ecs_cluster.cluster_name}/${module.ecs_services["blyss-be-api"].service_name}"
        ]
      },

      # ---------- ECS Cluster ----------
      {
        Sid    = "ECSClusterRead"
        Effect = "Allow"
        Action = [
          "ecs:DescribeClusters"
        ]
        Resource = [
          "arn:aws:ecs:${local.aws_region}:${local.account_id}:cluster/${module.ecs_cluster.cluster_name}"
        ]
      },

      # ---------- IAM (PassRole for ECS) ----------
      {
        Sid    = "PassRoleForECS"
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = [
          module.ecs_task_execution_role.role_arn,
          module.ecs_task_role.role_arn
        ]
      },

      # ---------- CloudWatch Logs ----------
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = [
          module.cloudwatch_log_groups["blyss-be-api"].log_group_arn,
          "${module.cloudwatch_log_groups["blyss-be-api"].log_group_arn}:*"
        ]
      }
    ]
  })

  role_policies = {}

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ci-cd"
    App         = "github-actions"
  }
}
