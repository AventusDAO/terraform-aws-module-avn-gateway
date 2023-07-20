#
# gateway rds
#
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.0"

  identifier = "aaaa"

  # All available versions: https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_PostgreSQL.html#PostgreSQL.Concepts
  engine                     = lookup(var.rds, "engine", "postgres")
  engine_version             = lookup(var.rds, "engine_version", "14.5")
  family                     = lookup(var.rds, "family", "postgres14")
  major_engine_version       = lookup(var.rds, "major_engine_version", "14")
  instance_class             = lookup(var.rds, "instance_class", "db.t4g.small")
  auto_minor_version_upgrade = lookup(var.rds, "auto_minor_version_upgrade", false)

  storage_type          = lookup(var.rds, "storage_type", "gp3")
  allocated_storage     = lookup(var.rds, "allocated_storage", 20)
  max_allocated_storage = lookup(var.rds, "allocated_storage", 50)

  username = lookup(var.rds, "username", "root")
  port     = lookup(var.rds, "port", 5432)

  multi_az               = lookup(var.rds, "multi_az", false)
  db_subnet_group_name   = aws_db_subnet_group.rds.id
  vpc_security_group_ids = [module.sg_rds.security_group_id]

  maintenance_window              = lookup(var.rds, "maintenance_window", "Tue:10:00-Tue:11:00")
  backup_window                   = lookup(var.rds, "backup_window", "07:00-08:00")
  enabled_cloudwatch_logs_exports = lookup(var.rds, "enabled_cloudwatch_logs_exports", ["postgresql", "upgrade"])
  create_cloudwatch_log_group     = lookup(var.rds, "create_cloudwatch_log_group", true)

  backup_retention_period = lookup(var.rds, "backup_retention_period", 7)
  skip_final_snapshot     = lookup(var.rds, "skip_final_snapshot", false)
  deletion_protection     = lookup(var.rds, "deletion_protection", true)

  performance_insights_enabled          = lookup(var.rds, "performance_insights_enabled", true)
  performance_insights_retention_period = lookup(var.rds, "performance_insights_retention_period", 7)
  create_monitoring_role                = lookup(var.rds, "create_monitoring_role", true)
  monitoring_interval                   = lookup(var.rds, "monitoring_interval", 60)
  monitoring_role_name                  = lookup(var.rds, "monitoring_role_name", "rds-gateway-db-monitoring")

  parameters = lookup(var.rds, "parameters",
    [
      {
        name  = "autovacuum"
        value = 1
      },
      {
        name  = "client_encoding"
        value = "utf8"
      }
    ]
  )

  tags = merge(lookup(var.rds, "tags", {}), { Name = lookup(var.rds, "override_name", var.name) })
}

resource "aws_db_subnet_group" "rds" {
  name        = "${lookup(var.rds, "override_name", var.name)}-db-group"
  description = "${lookup(var.rds, "override_name", var.name)} RDS Database subnet group"
  subnet_ids  = var.rds.subnet_ids

  tags = merge(lookup(var.rds, "tags", {}), { Name = lookup(var.rds, "override_name", var.name) })
}
