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
  description = "Zone id where to create cognito admin portal custom domain record."
}

#TODO: to be deleted when domain migration is finalised
variable "old_route53_zone_id" {
  type        = string
  description = "Zone id where to create the deprecated gateway api record and admin portal record."
}

variable "monitoring_sns_topic_arn" {
  type        = string
  description = "SNS topic ARN where to send alarms."
}

variable "memory_db" {
  type = object({
    subnet_ids                 = list(string)
    create                     = optional(bool, true)
    override_name              = optional(string) #if not set, var.name is used
    description                = optional(string, "Gateway MemoryDB cluster (redis)")
    engine_version             = optional(string, "6.2")
    auto_minor_version_upgrade = optional(bool, false)
    node_type                  = optional(string, "db.t4g.small")
    num_shards                 = optional(number, 1)
    num_replicas_per_shard     = optional(number, 2)
    port                       = optional(number, 6379)
    tls_enabled                = optional(bool, false)
    maintenance_window         = optional(string, "tue:09:00-tue:10:00")
    snapshot_name              = optional(string)
    snapshot_retention_limit   = optional(number, 14)
    snapshot_window            = optional(string, "06:00-07:00")
    create_parameter_group     = optional(bool, false)
    parameter_group_name       = optional(string, "default.memorydb-redis6")
    subnet_group_name          = optional(string)
    subnet_group_description   = optional(string)
    subnet_group_tags          = optional(map(any), {})
    tags                       = optional(map(any), {})
  })

  description = "Subset of AWS MemoryDB configurations used on 'terraform-aws-modules/memory-db/aws' module."
}

variable "rds" {
  type = object({
    subnet_ids                            = list(string)
    create                                = optional(bool, true)
    override_name                         = optional(string) #if not set, var.name is used
    engine                                = optional(string, "postgres")
    engine_version                        = optional(string, "14.10")
    family                                = optional(string, "postgres14")
    major_engine_version                  = optional(string, "14")
    instance_class                        = optional(string, "db.t4g.small")
    auto_minor_version_upgrade            = optional(bool, false)
    storage_type                          = optional(string, "gp3")
    allocated_storage                     = optional(number, 20)
    max_allocated_storage                 = optional(number, 50)
    username                              = optional(string, "root")
    port                                  = optional(number, 5432)
    snapshot_identifier                   = optional(string)
    ca_cert_identifier                    = optional(string, "rds-ca-ecc384-g1")
    multi_az                              = optional(bool, false)
    maintenance_window                    = optional(string, "Tue:10:00-Tue:11:00")
    backup_window                         = optional(string, "07:00-08:00")
    enabled_cloudwatch_logs_exports       = optional(list(string), ["postgresql", "upgrade"])
    create_cloudwatch_log_group           = optional(bool, true)
    backup_retention_period               = optional(number, 7)
    skip_final_snapshot                   = optional(bool, false)
    deletion_protection                   = optional(bool, true)
    performance_insights_enabled          = optional(bool, true)
    performance_insights_retention_period = optional(number, 7)
    create_monitoring_role                = optional(bool, true)
    monitoring_interval                   = optional(number, 60)
    monitoring_role_name                  = optional(string)
    parameters = optional(
      list(
        object(
          {
            name  = string
            value = any
          }
      )),
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
    tags = optional(map(any), {})
  })
  description = "Subset of AWS RDS configurations used on 'terraform-aws-modules/rds/aws' module."
}

variable "api_gateway" {
  type = object({
    custom_domain                   = string
    old_custom_domain               = optional(string) #TODO: remove this line when domain migration is finalised
    old_domain_name_certificate_arn = optional(string) #TODO: remove this line when domain migration is finalised
    domain_name_certificate_arn     = string
    override_name                   = optional(string) # if not set, var.name is used
    description                     = optional(string)
    protocol_type                   = optional(string, "HTTP")
    cors_configuration = optional(
      object({
        allow_credentials = optional(bool)
        allow_headers     = optional(list(string))
        allow_methods     = optional(list(string))
        allow_origins     = optional(list(string))
        expose_headers    = optional(list(string))
        max_age           = optional(number)
        }
      ),
      {
        allow_credentials = false
        allow_headers     = ["*"]
        allow_methods     = ["*"]
        allow_origins     = ["*"]
        expose_headers    = ["*"]
        max_age           = 100
      }
    )
    default_stage_access_log_format = optional(string) # more here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage#access_log_settings
    stage_default_route_settings = optional(
      object({
        detailed_metrics_enabled = optional(bool)
        throttling_burst_limit   = optional(number)
        throttling_rate_limit    = optional(number)
        }
      ),
      {
        detailed_metrics_enabled = true
        throttling_burst_limit   = 100
        throttling_rate_limit    = 100
      }
    )
    retention_in_days = optional(number, 14)
    tags              = optional(map(any), {})
  })
  description = "Subset of AWS API gateway configurations used on 'terraform-aws-modules/apigateway-v2/aws' module."
}

variable "lambdas" {
  type = object({
    vpc_subnet_ids            = list(string)
    extra_envs                = optional(bool, true)
    layer_compatible_runtimes = optional(list(string), ["nodejs14.x"])
    runtime                   = optional(string, "nodejs14.x")
    zip_location = optional(
      object({
        bucket     = optional(string)
        key_prefix = optional(string)
        }
      ),
      {
        bucket     = "aventus-internal-artefact"
        key_prefix = "gateway-lambdas"
      }
    )
    common_env_vars                   = optional(map(any), {})
    cloudwatch_logs_retention_in_days = optional(number, 14)
    authorisation_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = { MAX_TOKEN_AGE_MSEC = 600000, MIN_AVT_BALANCE = "1000000000000000000" }
        memory_size = 512
        timeout     = 30
      }
    )
    send_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        memory_size = 512
        timeout     = 30
      }
    )
    poll_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 256
        timeout     = 30
      }
    )
    query_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 256
        timeout     = 30
      }
    )
    lift_processing_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 256
        timeout     = 30
      }
    )
    tx_status_update_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 256
        timeout     = 30
      }
    )
    vote_handler = optional(
      object({
        env_vars                      = optional(map(any), {})
        memory_size                   = optional(number, 256)
        timeout                       = optional(number, 30)
        override_event_source_mapping = optional(map(any), null)
        vote_bucket                   = string
        }
      )
    )
    lower_handler = optional(
      object({
        env_vars                      = optional(map(any))
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 256
        timeout     = 30
      }
    )
    split_fee_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 512
        timeout     = 30
      }
    )
    tx_dispatch_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 512
        timeout     = 30
      }
    )
    invalid_transaction_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 512
        timeout     = 30
      }
    )

    webhooks_event_emitter_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 512
        timeout     = 30
      }
    )

    webhooks_verification_key_handler = optional(
      object({
        env_vars                      = optional(map(any))
        extra_policy_document         = optional(string)
        memory_size                   = optional(number)
        timeout                       = optional(number)
        override_event_source_mapping = optional(map(any), null)
        }
      ),
      {
        env_vars    = {}
        memory_size = 512
        timeout     = 30
      }
    )
  })
  description = "Subset of AWS gateway lambdas and layers configurations used on 'terraform-aws-modules/lambda/aws' module."
}

variable "sqs" {
  type = object({
    default_queue_name            = string
    payer_queue_name              = string
    tx_queue_name                 = string
    webhooks_queue_name           = string
    fifo                          = optional(bool, true)
    message_retention_seconds     = optional(number, 86400)
    visibility_timeout_seconds    = optional(number, 60)
    create_dlq                    = optional(bool, true)
    dlq_message_retention_seconds = optional(number, 1209600)
    receive_wait_time_seconds     = optional(number, 10)
    max_receive_count             = optional(number, 3)
    delay_seconds                 = optional(number, 1)
    dlq_delay_seconds             = optional(number, 0)
    alarm = object({
      alarm_description   = optional(string)
      comparison_operator = optional(string, "GreaterThanOrEqualToThreshold")
      evaluation_periods  = optional(number, 1)
      threshold           = optional(number, 20)
      period              = optional(number, 300)
      unit                = optional(string, "Count")
      namespace           = optional(string, "AWS/SQS")
      metric_name         = optional(string, "NumberOfMessagesSent")
      statistic           = optional(string, "Sum")
      alarm_actions       = string
    })
  })
  description = "List of FIFO queue names to create and its global configurations. Alarms for more than 20 messages on the DLQ will also be created."
}

variable "cognito" {
  type = object({
    domain                       = string
    certificate_arn              = string
    override_name                = optional(string) # if not set, var.name is used
    recovery_mechanism           = optional(list(string), ["verified_email"])
    allow_admin_create_user_only = optional(bool, true)
    password_policy = optional(
      object({
        minimum_length                   = optional(number)
        require_lowercase                = optional(bool)
        require_numbers                  = optional(bool)
        require_symbols                  = optional(bool)
        require_uppercase                = optional(bool)
        temporary_password_validity_days = optional(number)
        }
      ),
      {
        minimum_length                   = 12
        require_lowercase                = true
        require_numbers                  = true
        require_symbols                  = true
        require_uppercase                = true
        temporary_password_validity_days = 1
      }
    )
    software_token_mfa_configuration = optional(bool, true)
    user_pool_add_ons                = optional(string, "OFF")
    device_configuration = optional(
      object({
        challenge_required_on_new_device      = optional(bool)
        device_only_remembered_on_user_prompt = optional(bool)
        }
      ),
      {
        challenge_required_on_new_device      = true
        device_only_remembered_on_user_prompt = true
      }
    )
    deletion_protection = optional(string, "ACTIVE")
    mfa_configuration   = optional(string, "OPTIONAL")
    username_attributes = optional(list(string), ["email"])
    pool_client = object({
      callback_urls                        = list(string)
      logout_urls                          = list(string)
      generate_secret                      = optional(bool, true)
      allowed_oauth_flows_user_pool_client = optional(bool, true)
      allowed_oauth_flows                  = optional(list(string), ["code"])
      explicit_auth_flows = optional(
        list(string),
        [
          "ALLOW_CUSTOM_AUTH",
          "ALLOW_REFRESH_TOKEN_AUTH",
          "ALLOW_USER_PASSWORD_AUTH",
          "ALLOW_USER_SRP_AUTH"
        ]
      )
      allowed_oauth_scopes          = optional(list(string), ["email", "openid"])
      prevent_user_existence_errors = optional(string, "ENABLED")
      supported_identity_providers  = optional(list(string), ["COGNITO"])
    })
    extra_user_groups = optional(list(object({
      name        = string
      description = optional(string)
    })), [])
    tags = optional(map(any), {})
  })
  description = "Subset of AWS Cognito configurations used on 'terraform-aws-modules/apigateway-v2/aws' module."
}
