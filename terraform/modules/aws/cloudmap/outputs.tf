output "namespace_arn" {
  description = "ARN of the service discovery namespace"
  value = coalesce(
    try(aws_service_discovery_private_dns_namespace.this[0].arn, ""),
    try(aws_service_discovery_http_namespace.this[0].arn, "")
  )
}

output "namespace_id" {
  description = "ID of the service discovery namespace"
  value = coalesce(
    try(aws_service_discovery_private_dns_namespace.this[0].id, ""),
    try(aws_service_discovery_http_namespace.this[0].id, "")
  )
}

output "namespace_name" {
  description = "Name of the service discovery namespace"
  value = coalesce(
    try(aws_service_discovery_private_dns_namespace.this[0].name, ""),
    try(aws_service_discovery_http_namespace.this[0].name, "")
  )
}

output "namespace_type" {
  description = "Type of the service discovery namespace (private-dns or http)"
  value = var.create_private_dns_namespace ? "private-dns" : (
    var.create_http_namespace ? "http" : ""
  )
}

output "private_dns_namespace" {
  description = "Map containing private DNS namespace details"
  value = var.create_private_dns_namespace ? {
    arn  = try(aws_service_discovery_private_dns_namespace.this[0].arn, "")
    id   = try(aws_service_discovery_private_dns_namespace.this[0].id, "")
    name = try(aws_service_discovery_private_dns_namespace.this[0].name, "")
    vpc  = try(aws_service_discovery_private_dns_namespace.this[0].vpc, "")
  } : null
}

output "http_namespace" {
  description = "Map containing HTTP namespace details"
  value = var.create_http_namespace ? {
    arn  = try(aws_service_discovery_http_namespace.this[0].arn, "")
    id   = try(aws_service_discovery_http_namespace.this[0].id, "")
    name = try(aws_service_discovery_http_namespace.this[0].name, "")
  } : null
}

output "service_ids" {
  description = "Map of service names to their IDs"
  value       = { for k, v in aws_service_discovery_service.this : k => v.id }
}

output "service_arns" {
  description = "Map of service names to their ARNs"
  value       = { for k, v in aws_service_discovery_service.this : k => v.arn }
}
