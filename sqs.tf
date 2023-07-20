module "sqs_queues" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.2"

  name                          = lookup(var.sqs, "queue_names", ["gateway_default_queue", "gateway_payer_queue"])
  fifo_queue                    = lookup(var.sqs, "fifo_queue", true)
  message_retention_seconds     = lookup(var.sqs, "message_retention_seconds", 86400)
  visibility_timeout_seconds    = lookup(var.sqs, "visibility_timeout_seconds", 60)
  create_dlq                    = lookup(var.sqs, "create_dlq", true)
  dlq_message_retention_seconds = lookup(var.sqs, "dlq_message_retention_seconds", 1209600)
  receive_wait_time_seconds     = lookup(var.sqs, "receive_wait_time_seconds", 0)

  redrive_policy = {
    maxReceiveCount = lookup(var.sqs, "max_receive_count", 5)
  }

  tags = { Name = each.key }

  for_each = toset(var.sqs.queue_names)
}

module "gateway_sqs_queues_alarms" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.3.0"

  alarm_name          = replace("${each.key}_dlq_alarm", "-", "_")
  alarm_description   = lookup(var.sqs.alarm, "alarm_description", "Warning: DLQ queue [${each.key}] has more than 20 messages in the queue. Please investigate and take appropriate actions to avoid service disruption.")
  comparison_operator = lookup(var.sqs.alarm, "comparison_operator", "GreaterThanOrEqualToThreshold")
  evaluation_periods  = lookup(var.sqs.alarm, "evaluation_periods", 1)
  threshold           = lookup(var.sqs.alarm, "threshold", 20)
  period              = lookup(var.sqs.alarm, "period", 300)
  unit                = lookup(var.sqs.alarm, "unit", "Count")
  namespace           = lookup(var.sqs.alarm, "namespace", "AWS/SQS")
  metric_name         = lookup(var.sqs.alarm, "metric_name", "NumberOfMessagesSent")
  statistic           = lookup(var.sqs.alarm, "statistic", "Sum")
  dimensions          = lookup(var.sqs.alarm, "dimensions", { QueueName = each.key })
  alarm_actions       = [var.sqs.alarm.alarm_actions]

  for_each = toset(var.sqs.queue_names)
}
