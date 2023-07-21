#
# gateway amazonmq (rabbitmq)
#
module "amazonmq" {
  source  = "cloudposse/mq-broker/aws"
  version = "3.1.0"

  name                                 = coalesce(var.amazon_mq.override_name, var.name)
  apply_immediately                    = var.amazon_mq.apply_immediately
  auto_minor_version_upgrade           = var.amazon_mq.auto_minor_version_upgrade
  deployment_mode                      = var.amazon_mq.deployment_mode
  engine_type                          = var.amazon_mq.engine_type
  engine_version                       = var.amazon_mq.engine_version
  host_instance_type                   = var.amazon_mq.host_instance_type
  publicly_accessible                  = var.amazon_mq.publicly_accessible
  general_log_enabled                  = var.amazon_mq.general_log_enabled
  audit_log_enabled                    = var.amazon_mq.audit_log_enabled
  encryption_enabled                   = var.amazon_mq.encryption_enabled
  use_aws_owned_key                    = true
  vpc_id                               = var.vpc_id
  subnet_ids                           = var.amazon_mq.subnet_ids
  create_security_group                = false
  associated_security_group_ids        = [module.sg_amazonmq.security_group_id]
  security_group_create_before_destroy = true

  # Lambda is connecting to amazonmq by fetching username and password keys
  mq_application_user     = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["username"]]
  mq_application_password = [jsondecode(data.aws_secretsmanager_secret_version.amazonmq.secret_string)["password"]]
}
