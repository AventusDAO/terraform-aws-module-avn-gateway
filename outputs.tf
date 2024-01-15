output "rds" {
  description = "RDS outputs"
  value = tomap({
    "db_instance_identifier" = try(module.rds[0].db_instance_identifier, null)
  })
}
