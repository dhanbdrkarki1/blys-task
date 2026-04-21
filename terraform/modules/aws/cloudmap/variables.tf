variable "create_private_dns_namespace" {
  description = "Whether to create a private DNS namespace"
  type        = bool
  default     = false
}

variable "create_http_namespace" {
  description = "Boolean flag to create HTTP namespace"
  type        = bool
  default     = false
}

variable "namespace_name" {
  description = "Name of the namespace (e.g., project-name.local)"
  type        = string
  default     = null
}

variable "vpc_id" {
  description = "ID of the VPC to associate with the namespace"
  type        = string
  default     = null
}

variable "description" {
  description = "Description for the namespace"
  type        = string
  default     = ""
}

variable "custom_tags" {
  description = "Custom tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "services" {
  description = "Map of service discovery services to create"
  type = map(object({
    description       = optional(string)
    dns_ttl           = optional(number, 60)
    dns_type          = optional(string, "A")
    routing_policy    = optional(string, "MULTIVALUE")
    failure_threshold = optional(number, 1)
    force_destroy     = optional(bool, false)
    tags              = optional(map(string), {})
  }))
  default = {}
}
