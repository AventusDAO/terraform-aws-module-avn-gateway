#
# gateway memory_db (redis)
#
module "memory_db" {
  source  = "terraform-aws-modules/memory-db/aws"
  version = "v1.1.2"

  count = var.memory_db.create ? 1 : 0

  # Cluster
  name        = coalesce(var.memory_db.override_name, var.name)
  description = var.memory_db.description

  engine_version             = var.memory_db.engine_version
  auto_minor_version_upgrade = var.memory_db.auto_minor_version_upgrade
  node_type                  = var.memory_db.node_type
  num_shards                 = var.memory_db.num_shards
  num_replicas_per_shard     = var.memory_db.num_replicas_per_shard
  snapshot_name              = var.memory_db.snapshot_name

  port                     = var.memory_db.port
  tls_enabled              = var.memory_db.tls_enabled
  security_group_ids       = [module.sg_memorydb[0].security_group_id]
  maintenance_window       = var.memory_db.maintenance_window
  sns_topic_arn            = var.memory_db.sns_topic_arn
  snapshot_retention_limit = var.memory_db.snapshot_retention_limit
  snapshot_window          = var.memory_db.snapshot_window

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
  create_parameter_group = var.memory_db.create_parameter_group
  parameter_group_name   = var.memory_db.parameter_group_name

  # Subnet group
  subnet_group_name        = coalesce(var.memory_db.subnet_group_name, "${coalesce(var.memory_db.override_name, var.name)}-subnet-group")
  subnet_group_description = coalesce(var.memory_db.subnet_group_description, "${coalesce(var.memory_db.override_name, var.name)} MemoryDB subnet group")
  subnet_ids               = var.memory_db.subnet_ids
  subnet_group_tags        = var.memory_db.subnet_group_tags

  tags = merge(var.memory_db.tags, { Name = coalesce(var.memory_db.override_name, var.name) })
}
