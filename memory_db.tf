#
# gateway memory_db (redis)
#
module "memory_db" {
  source  = "terraform-aws-modules/memory-db/aws"
  version = "v1.1.2"

  # Cluster
  name        = lookup(var.memory_db, "override_name", var.name)
  description = lookup(var.memory_db, "description", "Gateway MemoryDB cluster (redis)")

  engine_version             = lookup(var.memory_db, "engine_version", "6.2")
  auto_minor_version_upgrade = lookup(var.memory_db, "auto_minor_version_upgrade", false)
  node_type                  = lookup(var.memory_db, "node_type", "db.t4g.small")
  num_shards                 = lookup(var.memory_db, "num_shards", 1)
  num_replicas_per_shard     = lookup(var.memory_db, "num_replicas_per_shard", 3)

  port                     = lookup(var.memory_db, "port", 6379)
  tls_enabled              = lookup(var.memory_db, "tls_enabled", false)
  security_group_ids       = [module.sg_memorydb.security_group_id]
  maintenance_window       = lookup(var.memory_db, "maintenance_window", "tue:09:00-tue:10:00")
  sns_topic_arn            = var.memory_db.sns_topic_arn
  snapshot_retention_limit = lookup(var.memory_db, "snapshot_retention_limit", 14)
  snapshot_window          = lookup(var.memory_db, "snapshot_window", "06:00-07:00")

  #TODO: revisit Users and ACL - for now avn-connector doesn't allow configuring a user to connect to redis (it uses the default one)
  # Should create an admin and connector (with limited access) user and add it to a specific ACL.
  # Then, avn-connector should use the connector user to connect to redis
  #
  # Users
  create_users = false
  # ACL
  create_acl = false
  acl_name   = "open-access"

  # Parameter group
  create_parameter_group = lookup(var.memory_db, "create_parameter_group", false)
  parameter_group_name   = lookup(var.memory_db, "parameter_group_name", "default.memorydb-redis6")

  # Subnet group
  subnet_group_name        = lookup(var.memory_db, "subnet_group_name", "${lookup(var.memory_db, "override_name", var.name)}-subnet-group")
  subnet_group_description = lookup(var.memory_db, "subnet_group_description", "${lookup(var.memory_db, "override_name", var.name)} MemoryDB subnet group")
  subnet_ids               = var.memory_db.subnet_ids
  subnet_group_tags        = lookup(var.memory_db, "subnet_group_tags", {})

  tags = merge(lookup(var.memory_db, "tags", {}), { Name = lookup(var.memory_db, "override_name", var.name) })
}