output "rds" {
  description = "RDS outputs"
  value = tomap({
    "db_instance_identifier" = module.rds.db_instance_identifier
  })
}
