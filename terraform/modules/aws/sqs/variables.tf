#################################
# SQS
#################################

variable "create" {
  default     = false
  type        = bool
  description = "Specify whether to create resources or not"
}

variable "name" {
  description = "Base name of the SQS queue."
  type        = string
}

variable "fifo_queue" {
  description = "Boolean designating a FIFO queue."
  type        = bool
  default     = false
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue."
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "How long, in seconds, messages are retained."
  type        = number
  default     = 345600
}

variable "receive_wait_time_seconds" {
  description = "Long polling wait time in seconds."
  type        = number
  default     = 0
}

variable "sqs_tags" {
  description = "Tags to set on SQS queue."
  type        = map(string)
  default     = {}
}

variable "custom_tags" {
  description = "Custom tags to set on all resources."
  type        = map(string)
  default     = {}
}
