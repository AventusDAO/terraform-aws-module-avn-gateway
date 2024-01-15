output "rds" {
  description = "RDS outputs"
  value = tomap({
    "db_instance_identifier" = module.rds.outputs.db_instance_identifier
  })
}
