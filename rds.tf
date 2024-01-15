#
# gateway rds
#
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"

  count = var.rds.create ? 1 : 0

  identifier = coalesce(var.rds.override_name, var.name)

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                     = var.rds.engine
  engine_version             = var.rds.engine_version
  family                     = var.rds.family
  major_engine_version       = var.rds.major_engine_version
  instance_class             = var.rds.instance_class
  auto_minor_version_upgrade = var.rds.auto_minor_version_upgrade
  storage_type               = var.rds.storage_type
  allocated_storage          = var.rds.allocated_storage
  max_allocated_storage      = var.rds.max_allocated_storage
  username                   = var.rds.username
  port                       = var.rds.port
  snapshot_identifier        = var.rds.snapshot_identifier
  ca_cert_identifier         = var.rds.ca_cert_identifier

  multi_az               = var.rds.multi_az
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [module.sg_rds[0].security_group_id]

  maintenance_window              = var.rds.maintenance_window
  backup_window                   = var.rds.backup_window
  enabled_cloudwatch_logs_exports = var.rds.enabled_cloudwatch_logs_exports
  create_cloudwatch_log_group     = var.rds.create_cloudwatch_log_group

  backup_retention_period = var.rds.backup_retention_period
  skip_final_snapshot     = var.rds.skip_final_snapshot
  deletion_protection     = var.rds.deletion_protection

  performance_insights_enabled          = var.rds.performance_insights_enabled
  performance_insights_retention_period = var.rds.performance_insights_retention_period
  create_monitoring_role                = var.rds.create_monitoring_role
  monitoring_interval                   = var.rds.monitoring_interval
  monitoring_role_name                  = coalesce(var.rds.monitoring_role_name, "rds-${coalesce(var.rds.override_name, var.name)}-db-monitoring")

  parameters = var.rds.parameters

  tags = merge(var.rds.tags, { Name = coalesce(var.rds.override_name, var.name) })
}

resource "aws_db_subnet_group" "rds" {
  name        = "${coalesce(var.rds.override_name, var.name)}-db-group"
  description = "${coalesce(var.rds.override_name, var.name)} RDS Database subnet group"
  subnet_ids  = var.rds.subnet_ids

  tags = merge(var.rds.tags, { Name = coalesce(var.rds.override_name, var.name) })
}

module "rds_monitoring" {
  source = "git@github.com:Aventus-Network-Services/terraform-aws-rds-monitoring?ref=v0.1.0"

  sns_topic         = [var.monitoring_sns_topic_arn]
  alarm_name_prefix = module.rds[0].db_instance_identifier
  db_instance_id    = module.rds[0].db_instance_identifier
  tags              = var.rds.tags
}
