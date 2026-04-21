#################################
# SQS
#################################

output "queue_name" {
  value = try(aws_sqs_queue.this[0].name, null)
}

output "queue_arn" {
  value = try(aws_sqs_queue.this[0].arn, null)
}

output "queue_url" {
  value = try(aws_sqs_queue.this[0].url, null)
}
