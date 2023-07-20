#
# gateway amazonmq (rabbitmq)
#
module "amazonmq" {
  source  = "cloudposse/mq-broker/aws"
  version = "3.1.0"

  name                                 = lookup(var.amazon_mq, "override_name", var.name)
  apply_immediately                    = lookup(var.amazon_mq, "apply_immediately", false)
  auto_minor_version_upgrade           = lookup(var.amazon_mq, "auto_minor_version_upgrade", false)
  deployment_mode                      = lookup(var.amazon_mq, "deployment_mode", "CLUSTER_MULTI_AZ")
  engine_type                          = lookup(var.amazon_mq, "engine_type", "RabbitMQ")
  engine_version                       = lookup(var.amazon_mq, "engine_version", "3.10.20")
  host_instance_type                   = lookup(var.amazon_mq, "host_instance_type", "mq.m5.large")
  publicly_accessible                  = lookup(var.amazon_mq, "publicly_accessible", false)
  general_log_enabled                  = lookup(var.amazon_mq, "general_log_enabled", true)
  audit_log_enabled                    = lookup(var.amazon_mq, "audit_log_enabled", false)
  encryption_enabled                   = lookup(var.amazon_mq, "encryption_enabled", true)
  use_aws_owned_key                    = true
  vpc_id                               = var.vpc_id
  subnet_ids                           = var.amazon_mq.subnet_ids
  create_security_group                = false
  associated_security_group_ids        = [module.sg_amazonmq.security_group_id]
  security_group_create_before_destroy = true

  mq_admin_user     = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["admin_user"]]
  mq_admin_password = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["admin_passw"]]
  # Lambda is connecting to amazonmq by fetching username and password keys
  mq_application_user     = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["username"]]
  mq_application_password = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["password"]]
}
