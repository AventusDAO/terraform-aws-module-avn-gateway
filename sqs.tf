module "sqs_queues" {
  source  = "terraform-aws-modules/sqs/aws"
  version = "4.0.2"

  name                          = each.key
  fifo_queue                    = var.sqs.fifo
  message_retention_seconds     = var.sqs.message_retention_seconds
  visibility_timeout_seconds    = var.sqs.visibility_timeout_seconds
  create_dlq                    = var.sqs.create_dlq
  dlq_message_retention_seconds = var.sqs.dlq_message_retention_seconds
  receive_wait_time_seconds     = var.sqs.receive_wait_time_seconds
  delay_seconds                 = var.sqs.delay_seconds
  dlq_delay_seconds             = var.sqs.dlq_delay_seconds

  redrive_policy = {
    maxReceiveCount = var.sqs.max_receive_count
  }

  tags = { Name = each.key }

  for_each = toset([var.sqs.default_queue_name, var.sqs.payer_queue_name, var.sqs.tx_queue_name])
}

module "gateway_sqs_queues_alarms" {
  source  = "terraform-aws-modules/cloudwatch/aws//modules/metric-alarm"
  version = "4.3.0"

  alarm_name          = replace("${each.key}-dlq-alarm", "_", "-")
  alarm_description   = coalesce(var.sqs.alarm.alarm_description, "Warning: DLQ queue [${each.key}-dlq.fifo] has more than 20 messages in the queue. Please investigate and take appropriate actions to avoid service disruption.")
  comparison_operator = var.sqs.alarm.comparison_operator
  evaluation_periods  = var.sqs.alarm.evaluation_periods
  threshold           = var.sqs.alarm.threshold
  period              = var.sqs.alarm.period
  unit                = var.sqs.alarm.unit
  namespace           = var.sqs.alarm.namespace
  metric_name         = var.sqs.alarm.metric_name
  statistic           = var.sqs.alarm.statistic
  dimensions          = { QueueName = "${each.key}-dlq.fifo" }
  alarm_actions       = [var.sqs.alarm.alarm_actions]

  for_each = toset([var.sqs.default_queue_name, var.sqs.payer_queue_name, var.sqs.tx_queue_name])
}
