locals {
  # Common configurations
  common_lambda_config = {
    allowed_triggers = local.common_lambda_permissions
    memory_size      = 256 # Default size unless overridden
    timeout          = 30  # Default timeout unless overridden
  }

  # Common SQS URLs used across multiple lambdas
  sqs_urls = {
    default = module.sqs_queues[var.sqs.default_queue_name].queue_url
    payer   = module.sqs_queues[var.sqs.payer_queue_name].queue_url
    tx      = module.sqs_queues[var.sqs.tx_queue_name].queue_url
  }

  # Common SQS ARNs
  sqs_arns = {
    default     = module.sqs_queues[var.sqs.default_queue_name].queue_arn
    payer       = module.sqs_queues[var.sqs.payer_queue_name].queue_arn
    tx          = module.sqs_queues[var.sqs.tx_queue_name].queue_arn
    webhooks    = module.sqs_queues[var.sqs.webhooks_queue_name].queue_arn
    dlq_default = module.sqs_queues[var.sqs.default_queue_name].dead_letter_queue_arn
    dlq_payer   = module.sqs_queues[var.sqs.payer_queue_name].dead_letter_queue_arn
  }

  # Common event source mapping configuration
  event_source_mapping_config = {
    batch_failure = {
      function_response_types = ["ReportBatchItemFailures"]
    }
  }

  # secrets
  sm = {
    admin-portal = {
      value = {
        cognitoRegion           = data.aws_region.current.name
        cloudwatchRegion        = data.aws_region.current.name
        cognitoPoolId           = aws_cognito_user_pool.admin_portal.id
        userPoolClientId        = aws_cognito_user_pool_client.admin_portal.id
        cognitoAuthUrl          = var.cognito.aws_domain != null ? "https://${var.cognito.aws_domain}.auth.${data.aws_region.current.name}.amazoncognito.com" : "https://${var.cognito.domain}"
        cognitoLoginRedirectUrl = "https://${var.cognito.domain_admin_portal}/login"
        corsAllowedUrl          = "https://${var.cognito.domain_admin_portal}"
        backendUrl              = ""
        cognitoLogoutUrl        = "https://${var.cognito.domain_admin_portal}/logout"
        redisUrl                = module.memory_db.redis_endpoint
        logGroups = join(", ", concat(
          [for handler in ["split_fee_handler", "send_handler", "authorisation_handler", "invalid_transaction_handler", "tx_dispatch_handler"] :
            module.lambdas[handler].lambda_cloudwatch_log_group_name
          ],
          ["/aws/eks/fluentbit-cloudwatch/workload/gateway"]
        ))
      }
    }
    rds = {
      value = {
        gateway_app_user          = "gateway_app"
        gateway_app_database      = "gateway_app_db"
        gateway_app_user_password = ""
        gateway_rds_host          = try(module.rds[0].db_instance_address, null)
        gateway_app_schema_sync   = tostring(false)
        db_explorer_host          = ""
        db_explorer_user          = "explorer_ro"
        db_explorer_pass          = ""
        db_explorer_balances_name = "explorer_balances_db"
        db_explorer_fees_name     = "explorer_fees_db"
      }
    }
    cognito = {
      value = {
        client_secret = aws_cognito_user_pool_client.admin_portal.client_secret
      }
    }
    vault = {
      value = {
        avn_vault_authority_username = "",
        avn_vault_authority_password = "",
        avn_vault_authority_mnemonic = "",
        avn_vault_relayer_username   = "",
        avn_vault_relayer_password   = "",
        avn_vault_relayer_seed       = "",
        vault_app_role_id            = "",
        vault_app_secret_id          = ""
      }
    }
    connector = {
      value = {
        tier1_provider_url = ""
        autolower_pk       = ""
      }
    }
  }

  # lambdas
  lambda_layers = toset(["common"])

  lambdas = {
    authorisation_handler = {
      env_vars                      = var.lambdas.authorisation_handler.env_vars
      memory_size                   = var.lambdas.authorisation_handler.memory_size
      timeout                       = var.lambdas.authorisation_handler.timeout
      override_event_source_mapping = var.lambdas.authorisation_handler.override_event_source_mapping
      allowed_triggers              = local.common_lambda_permissions
    }
    send_handler = merge(var.lambdas.send_handler, {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          SQS_DEFAULT_QUEUE_URL = local.sqs_urls.default
          SQS_PAYER_QUEUE_URL   = local.sqs_urls.payer
        },
        var.lambdas.send_handler.env_vars
      ) : var.lambdas.send_handler.env_vars
      extra_policy_arn = aws_iam_policy.gateway_send_handler_access.arn
    })
    poll_handler                      = var.lambdas.poll_handler
    query_handler                     = var.lambdas.query_handler
    lift_processing_handler           = var.lambdas.lift_processing_handler
    tx_status_update_handler          = var.lambdas.tx_status_update_handler
    vote_handler                      = var.lambdas.vote_handler
    lower_handler                     = var.lambdas.lower_handler
    split_fee_handler                 = var.lambdas.split_fee_handler
    tx_dispatch_handler               = var.lambdas.tx_dispatch_handler
    webhooks_event_emitter_handler    = var.lambdas.webhooks_event_emitter_handler
    webhooks_verification_key_handler = var.lambdas.webhooks_verification_key_handler
    invalid_transaction_handler       = var.lambdas.invalid_transaction_handler
  }

  common_lambda_permissions = {
    allow_api_gateway = {
      statement_id = "AllowAPIgatewayInvocation"
      service      = "apigateway"
      source_arn   = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${module.api_gateway.api_id}/*"
    }
  }

  # Cognito user groups
  defaults_cognito_user_groups = [
    for group in ["admin", "ops", "payer", "read", "relayer", "write"] : {
      name        = group
      description = "Group to grant ${group} permission to users of the admin portal."
    }
  ]

  #
  # additional RDS cidr to allow access
  #
  rds_cidrs = [
    for cidr in var.rds.allowed_cidr_blocks : {
      rule        = "postgresql-tcp"
      protocol    = "tcp"
      description = "Allow traffic on gateway-rds port"
      cidr_blocks = cidr
    }
  ]

  # TODO: New lambda configuration format to be implemented after testing
  /*
  new_lambda_config = {
    for name, config in local.lambdas : name => merge(
      local.common_lambda_config,
      config
    )
  }
  */
}
