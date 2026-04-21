variable "create" {
  description = "Specify whether to create the resources or not."
  type        = bool
  default     = false
}

# Service-Linked Role
variable "create_service_linked_role" {
  description = "Whether to create a service-linked role"
  type        = bool
  default     = false
}

variable "service_linked_role_service" {
  description = "The AWS service name for the service-linked role (e.g., ecs.amazonaws.com)"
  type        = string
  default     = null
}

variable "service_linked_role_description" {
  description = "Description of the service-linked role"
  type        = string
  default     = null
}

# Role
variable "role_name" {
  description = "Name of the IAM role"
  type        = string
  default     = ""
}

variable "role_description" {
  description = "Description of the IAM role"
  type        = string
  default     = null
}

variable "assume_role_policy" {
  description = "Assume role policy document"
  type        = string
  default     = null
}

variable "role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default     = {}
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  default     = ""
}

variable "policy_description" {
  description = "Description of the IAM policy"
  type        = string
  default     = null
}

variable "policy_document" {
  description = "Policy document (only support JSON encoded)"
  type        = string
  default     = null
}

variable "create_ec2_instance_profile" {
  description = "Determines whether an EC2 instance profile is created or to use an existing IAM instance profile"
  type        = bool
  default     = false
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}


# IAM Users and Groups
variable "create_users" {
  description = "Whether to create IAM users"
  type        = bool
  default     = false
}

variable "create_groups" {
  description = "Whether to create IAM groups"
  type        = bool
  default     = false
}

variable "users" {
  description = "Map of user names to their configurations"
  type = map(object({
    path        = optional(string, "/")
    groups      = optional(list(string), [])
    policy_arns = optional(list(string), [])
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "groups" {
  description = "Map of group names to their configurations"
  type = map(object({
    path             = optional(string, "/")
    managed_policies = optional(list(string), [])
    custom_policies  = optional(list(string), [])
  }))
  default = {}
}

variable "custom_policies" {
  description = "Map of custom IAM policies to create"
  type = map(object({
    description = string
    policy      = any
    path        = optional(string, "/")
    tags        = optional(map(string), {})
  }))
  default = {}
}

variable "custom_tags" {
  description = "Custom tags to set on all the resources."
  type        = map(string)
  default     = {}
}

# OpenID Connect Provider
variable "create_oidc_provider" {
  description = "Whether to create an OpenID Connect provider"
  type        = bool
  default     = false
}

variable "oidc_provider_url" {
  description = "URL of the OIDC provider (e.g., https://token.actions.githubusercontent.com)"
  type        = string
  default     = null
}

variable "oidc_client_id_list" {
  description = "List of client IDs (audiences) for the OIDC provider"
  type        = list(string)
  default     = []
}

variable "oidc_thumbprint_list" {
  description = "List of server certificate thumbprints for the OIDC provider"
  type        = list(string)
  default     = []
}
