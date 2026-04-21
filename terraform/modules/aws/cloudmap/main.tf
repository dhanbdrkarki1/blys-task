# Service Discovery Private DNS Namespace
resource "aws_service_discovery_private_dns_namespace" "this" {
  count       = var.create_private_dns_namespace ? 1 : 0
  name        = var.namespace_name
  vpc         = var.vpc_id
  description = var.description
  tags        = var.custom_tags
}

# Service Discovery HTTP Namespace
resource "aws_service_discovery_http_namespace" "this" {
  count       = var.create_http_namespace ? 1 : 0
  name        = var.namespace_name
  description = var.description
  tags        = var.custom_tags
}

# Service Discovery Service
resource "aws_service_discovery_service" "this" {
  for_each = length(var.services) > 0 ? var.services : {}

  name        = each.key
  description = try(each.value.description, "Service discovery for ${each.key}")

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this[0].id

    dns_records {
      ttl  = try(each.value.dns_ttl, 60)
      type = try(each.value.dns_type, "A")
    }

    routing_policy = try(each.value.routing_policy, "MULTIVALUE")
  }

  health_check_custom_config {
    failure_threshold = try(each.value.failure_threshold, 1)
  }

  force_destroy = try(each.value.force_destroy, false)
  tags          = merge(var.custom_tags, try(each.value.tags, {}))
}
