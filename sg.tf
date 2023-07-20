#
# gateway rds
#
module "sg_rds" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = lookup(var.rds, "override_name", "${var.name}-rds")
  description = "${lookup(var.rds, "override_name", "${var.name}-rds")} access"

  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      rule        = "postgresql-tcp"
      protocol    = "tcp"
      description = "Allow traffic on gateway-rds port"
      cidr_blocks = data.aws_vpc.current.cidr_block
    },
  ]

  tags = merge(lookup(var.rds, "tags", {}), { Name = lookup(var.rds, "override_name", var.name) })
}

#
# gateway memory db
#
module "sg_memorydb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = lookup(var.rds, "override_name", "${var.name}-memorydb")
  description = "${lookup(var.rds, "override_name", "${var.name}-memorydb")} access"

  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = module.memory_db.cluster_endpoint_port
      to_port     = module.memory_db.cluster_endpoint_port
      protocol    = "tcp"
      description = "Allow traffic on gateway-memory db port"
      cidr_blocks = data.aws_vpc.current.cidr_block
    },
  ]

  tags = merge(lookup(var.memory_db, "tags", {}), { Name = lookup(var.memory_db, "override_name", var.name) })
}

#
# gateway amq
#
module "sg_amazonmq" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = lookup(var.amazon_mq, "override_name", "${var.name}-amq")
  description = "${lookup(var.amazon_mq, "override_name", var.name)} amazon MQ access"

  vpc_id = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5671
      to_port     = 5671
      protocol    = "tcp"
      description = "Allow traffic on gateway-memory db port"
      cidr_blocks = data.aws_vpc.current.cidr_block
    },
  ]

  tags = merge(lookup(var.amazon_mq, "tags", {}), { Name = lookup(var.amazon_mq, "override_name", var.name) })
}

#
# gateway lambdas
#
module "sg_lambdas" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "${var.name}-lambdas"
  description = "${var.name} lambdas access"

  vpc_id = var.vpc_id

  ingress_rules       = ["all-all"]
  ingress_cidr_blocks = [data.aws_vpc.current.cidr_block]
  egress_rules        = ["all-all"]
  egress_cidr_blocks  = ["0.0.0.0/0"]

  tags = merge(lookup(var.lambdas, "tags", {}), { Name = var.name })
}