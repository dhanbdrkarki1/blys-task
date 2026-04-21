#================================
# AWS Systems Manager Parameter Store
#================================
module "app_parameters" {
  source = "../../modules/aws/ssm"
  create = true

  ssm_parameters = {
    for k, v in local.app_ssm_parameters : k => {
      name        = v.path
      description = v.description
      type        = "SecureString"
      value       = v.value
    }
  }

  custom_tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "configuration"
  }
}

#================================
# AWS Secrets Manager
#================================
module "app_secrets" {
  source   = "../../modules/aws/secrets_manager"
  for_each = local.app_secrets_manager
  create   = true

  name                  = each.value.name
  description           = each.value.description
  ignore_secret_changes = true
  secret_string         = "CHANGE_ME"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "secrets"
  }
}
