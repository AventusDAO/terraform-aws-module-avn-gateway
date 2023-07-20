variable "name" {
  type        = string
  description = "Full name used for all gateway AWS resources. The 'name' tag is also set."
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where to host the Gateway resources."
}

variable "eks_oidc_issuer_url" {
  type        = string
  description = "OIDC provider from the EKS cluster where the connector, admin portal and Vault are running."
}

variable "lambda_version" {
  type        = string
  default     = "latest"
  description = "(Optional) Commit hash of deployed lambdas. By default 'latest' is used."
}

variable "route53_zone_id" {
  type        = string
  description = "Zone id where to create gateway api record and admin portal record"
}

variable "amazon_mq" {
  type = object({
    subnet_ids                 = list(string)
    override_name              = optional(string) #if not set, var.name is used
    apply_immediately          = optional(bool)
    auto_minor_version_upgrade = optional(bool)
    deployment_mode            = optional(string)
    engine_type                = optional(string)
    engine_version             = optional(string)
    host_instance_type         = optional(string)
    publicly_accessible        = optional(bool)
    general_log_enabled        = optional(bool)
    audit_log_enabled          = optional(bool)
    encryption_enabled         = optional(bool)
  })
  description = "Subset of Amazon MQ cluster configurations used on 'cloudposse/mq-broker/aws' module."
}

variable "memory_db" {
  type = object({
    subnet_ids                 = list(string)
    sns_topic_arn              = string
    override_name              = optional(string) #if not set, var.name is used
    description                = optional(string)
    engine_version             = optional(string)
    auto_minor_version_upgrade = optional(bool)
    node_type                  = optional(string)
    num_shards                 = optional(number)
    num_replicas_per_shard     = optional(number)
    port                       = optional(number)
    tls_enabled                = optional(bool)
    maintenance_window         = optional(string)
    snapshot_retention_limit   = optional(number)
    snapshot_window            = optional(string)
    create_parameter_group     = optional(bool)
    parameter_group_name       = optional(string)
    subnet_group_name          = optional(string)
    subnet_group_description   = optional(string)
    subnet_group_tags          = optional(map(any))
    tags                       = optional(map(any))
  })

  description = "Subset of AWS MemoryDB configurations used on 'terraform-aws-modules/memory-db/aws' module."
}

variable "rds" {
  type = object({
    subnet_ids                            = list(string)
    override_name                         = optional(string) #if not set, var.name is used
    engine                                = optional(string)
    engine_version                        = optional(string)
    family                                = optional(string)
    major_engine_version                  = optional(string)
    instance_class                        = optional(string)
    auto_minor_version_upgrade            = optional(bool)
    storage_type                          = optional(string)
    allocated_storage                     = optional(number)
    max_allocated_storage                 = optional(number)
    username                              = optional(string)
    port                                  = optional(number)
    multi_az                              = optional(bool)
    maintenance_window                    = optional(string)
    backup_window                         = optional(string)
    enabled_cloudwatch_logs_exports       = optional(list(string))
    create_cloudwatch_log_group           = optional(bool)
    backup_retention_period               = optional(number)
    skip_final_snapshot                   = optional(bool)
    deletion_protection                   = optional(bool)
    performance_insights_enabled          = optional(bool)
    performance_insights_retention_period = optional(number)
    create_monitoring_role                = optional(bool)
    monitoring_interval                   = optional(number)
    monitoring_role_name                  = optional(string)
    parameters = optional(
      list(
        object(
          {
            name  = string
            value = number
          }
    )))
    tags = optional(map(any))
  })
  description = "Subset of AWS RDS configurations used on 'terraform-aws-modules/rds/aws' module."
}

variable "api_gateway" {
  type = object({
    domain_name_suffix          = string
    domain_name_certificate_arn = string
    override_name               = optional(string) # if not set, var.name is used
    description                 = optional(string)
    protocol_type               = optional(string)
    cors_configuration = optional(
      object({
        allow_credentials = optional(bool)
        allow_headers     = optional(list(string))
        allow_methods     = optional(list(string))
        allow_origins     = optional(list(string))
        expose_headers    = optional(list(string))
        max_age           = optional(number)
      })
    )
    default_stage_access_log_format = optional(map(any)) # more here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage#access_log_settings
    default_route_settings = optional(
      object({
        detailed_metrics_enabled = optional(bool)
        throttling_burst_limit   = optional(number)
        throttling_rate_limit    = optional(number)
      })
    )
    retention_in_days = optional(number)
    tags              = optional(map(any))
  })

  description = "Subset of AWS API gateway configurations used on 'terraform-aws-modules/apigateway-v2/aws' module."
}

variable "lambdas" {
  type = object({
    vpc_subnet_ids            = list(string)
    layer_compatible_runtimes = optional(list(string))
    runtime                   = optional(string)
    zip_location = optional(
      object({
        bucket     = optional(string) # bucket where to fetch lambda zips
        key_prefix = optional(string) # bucket key prefix where to fetch lambda zips
      })
    )
    common_env_vars                   = optional(map(any))
    cloudwatch_logs_retention_in_days = optional(number)
    authorisation_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    send_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    poll_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    query_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    lift_processing_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    tx_status_update_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    vote_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    lower_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    split_fee_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    tx_dispatch_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
    invalid_transaction_handler = optional(
      object({
        env_vars    = optional(map(any))
        memory_size = optional(number)
        timeout     = optional(number)
      })
    )
  })
  description = "Subset of AWS gateway lambdas and layers configurations used on 'terraform-aws-modules/lambda/aws' module."
}

variable "sqs" {
  type = object({
    queue_names                   = optional(list(string))
    fifo                          = optional(bool)
    message_retention_seconds     = optional(number)
    visibility_timeout_seconds    = optional(number)
    create_dlq                    = optional(bool)
    dlq_message_retention_seconds = optional(number)
    receive_wait_time_seconds     = optional(number)
    max_receive_count             = optional(number)
    alarms = optional(
      object({
        alarm_description   = optional(string)
        comparison_operator = optional(string)
        evaluation_periods  = optional(number)
        threshold           = optional(number)
        period              = optional(number)
        unit                = optional(string)
        namespace           = optional(string)
        metric_name         = optional(string)
        statistic           = optional(string)
        alarm_actions       = optional(string)
      })
    )
  })
  default     = {}
  description = "List of FIFO queue names to create and its global configurations. Alarms for more than 20 messages on the DLQ will also be created."
}

variable "cognito" {
  type = object({
    domain                       = string
    certificate_arn              = string
    override_name                = optional(string) # if not set, var.name is used
    recovery_mechanism           = optional(list(string))
    allow_admin_create_user_only = optional(bool)
    password_policy = optional(
      object({
        minimum_length                   = optional(number)
        require_lowercase                = optional(bool)
        require_numbers                  = optional(bool)
        require_symbols                  = optional(bool)
        require_uppercase                = optional(bool)
        temporary_password_validity_days = optional(number)
    }))
    software_token_mfa_configuration = optional(bool)
    user_pool_add_ons                = optional(string)
    device_configuration = optional(
      object({
        challenge_required_on_new_device      = optional(bool)
        device_only_remembered_on_user_prompt = optional(bool)
      })
    )
    deletion_protection = optional(string)
    mfa_configuration   = optional(string)
    username_attributes = optional(list(string))
    pool_client = object({
      callback_urls                        = list(string)
      logout_urls                          = list(string)
      user_pool_id                         = optional(string)
      generate_secret                      = optional(bool)
      allowed_oauth_flows_user_pool_client = optional(bool)
      allowed_oauth_flows                  = optional(list(string))
      explicit_auth_flows                  = optional(list(string))
      allowed_oauth_scopes                 = optional(list(string))
      prevent_user_existence_errors        = optional(string)
      supported_identity_providers         = optional(list(string))
    })
    tags = optional(map(any))
  })
}
