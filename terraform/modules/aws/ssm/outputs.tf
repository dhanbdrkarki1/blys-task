output "parameter_names" {
  value       = try({ for k, v in aws_ssm_parameter.this : k => v.name }, null)
  description = "The names of the created SSM parameters"
}

output "parameter_arns" {
  description = "The ARNs of the SSM parameters"
  value = try({
    for k, v in aws_ssm_parameter.this : k => v.arn
  }, null)
}
