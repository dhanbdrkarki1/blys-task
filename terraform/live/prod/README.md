<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.28.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_alb"></a> [alb](#module\_alb) | ../../modules/aws/alb | n/a |
| <a name="module_alb_sg"></a> [alb\_sg](#module\_alb\_sg) | ../../modules/aws/sg | n/a |
| <a name="module_app_parameters"></a> [app\_parameters](#module\_app\_parameters) | ../../modules/aws/ssm | n/a |
| <a name="module_app_secrets"></a> [app\_secrets](#module\_app\_secrets) | ../../modules/aws/secrets_manager | n/a |
| <a name="module_cloudmap"></a> [cloudmap](#module\_cloudmap) | ../../modules/aws/cloudmap | n/a |
| <a name="module_cloudwatch_log_groups"></a> [cloudwatch\_log\_groups](#module\_cloudwatch\_log\_groups) | ../../modules/aws/cloudwatch | n/a |
| <a name="module_ecr"></a> [ecr](#module\_ecr) | ../../modules/aws/ecr | n/a |
| <a name="module_ecs_cluster"></a> [ecs\_cluster](#module\_ecs\_cluster) | ../../modules/aws/ecs | n/a |
| <a name="module_ecs_services"></a> [ecs\_services](#module\_ecs\_services) | ../../modules/aws/ecs | n/a |
| <a name="module_ecs_sg"></a> [ecs\_sg](#module\_ecs\_sg) | ../../modules/aws/sg | n/a |
| <a name="module_ecs_task_execution_role"></a> [ecs\_task\_execution\_role](#module\_ecs\_task\_execution\_role) | ../../modules/aws/iam | n/a |
| <a name="module_ecs_task_role"></a> [ecs\_task\_role](#module\_ecs\_task\_role) | ../../modules/aws/iam | n/a |
| <a name="module_github_oidc_role"></a> [github\_oidc\_role](#module\_github\_oidc\_role) | ../../modules/aws/iam | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | ../../modules/aws/vpc | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.amazon_issued](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/acm_certificate) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | The list of availability zones names or ids in the region. | `list(string)` | `[]` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment of the project | `string` | `"test"` | no |
| <a name="input_github_repo"></a> [github\_repo](#input\_github\_repo) | GitHub repository name for backend | `string` | `""` | no |
| <a name="input_private_subnet_cidr_blocks"></a> [private\_subnet\_cidr\_blocks](#input\_private\_subnet\_cidr\_blocks) | List of CIDR blocks for private subnets | `list(string)` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the Project | `string` | n/a | yes |
| <a name="input_public_subnet_cidr_blocks"></a> [public\_subnet\_cidr\_blocks](#input\_public\_subnet\_cidr\_blocks) | List of CIDR blocks for public subnets | `list(string)` | n/a | yes |
| <a name="input_vpc_cidr_block"></a> [vpc\_cidr\_block](#input\_vpc\_cidr\_block) | The IPv4 CIDR block for the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_load_balancer_dns_name"></a> [load\_balancer\_dns\_name](#output\_load\_balancer\_dns\_name) | n/a |
<!-- END_TF_DOCS -->