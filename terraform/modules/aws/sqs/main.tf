#################################
# SQS
#################################

locals {
  name_prefix = lower(
    join("-",
      compact([
        lookup(var.custom_tags, "Project", "default"),
        lookup(var.custom_tags, "Environment", "default"),
        var.name
      ])
    )
  )
}

resource "aws_sqs_queue" "this" {
  count = var.create ? 1 : 0

  name                       = var.fifo_queue ? "${local.name_prefix}.fifo" : local.name_prefix
  fifo_queue                 = var.fifo_queue
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds

  tags = merge(
    { "Name" = local.name_prefix },
    var.sqs_tags,
    var.custom_tags
  )
}
