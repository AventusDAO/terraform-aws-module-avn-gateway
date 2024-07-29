locals {
  # secrets
  sm = {
    rds = {
      value = {
        root_user                 = ""
        root_password             = ""
        gateway_app_user          = ""
        gateway_app_database      = ""
        gateway_app_user_password = ""
        gateway_rds_host          = var.rds.create ? module.rds[0].db_instance_address : ""
        gateway_app_schema_sync   = false
        db_explorer_host          = ""
        db_explorer_user          = ""
        db_explorer_pass          = ""
        db_explorer_balances_name = ""
        db_explorer_fees_name     = ""
      }
    }
    cognito = {
      value = {
        client_secret = ""
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

  # To be removed at some point
  vault_secrets = {
    avn_vault_authority_username = "",
    avn_vault_authority_password = "",
    avn_vault_authority_mnemonic = "",
    avn_vault_relayer_username   = "",
    avn_vault_relayer_password   = "",
    avn_vault_relayer_seed       = "",
    vault_app_role_id            = "",
    vault_app_secret_id          = ""
  }

  rds_secrets = {
    root_user                 = ""
    root_password             = ""
    gateway_app_user          = ""
    gateway_app_database      = ""
    gateway_app_user_password = ""
    gateway_rds_host          = var.rds.create ? module.rds[0].db_instance_address : ""
    gateway_app_schema_sync   = false
  }
  ################################################################################ END of to be removed

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

    send_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          SQS_DEFAULT_QUEUE_URL = module.sqs_queues[var.sqs.default_queue_name].queue_url
          SQS_PAYER_QUEUE_URL   = module.sqs_queues[var.sqs.payer_queue_name].queue_url
        }, var.lambdas.send_handler.env_vars
      ) : var.lambdas.send_handler.env_vars

      memory_size                   = var.lambdas.send_handler.memory_size
      timeout                       = var.lambdas.send_handler.timeout
      extra_policy_arn              = aws_iam_policy.gateway_send_handler_access.arn
      override_event_source_mapping = var.lambdas.send_handler.override_event_source_mapping
      allowed_triggers              = local.common_lambda_permissions
    }

    poll_handler = {
      env_vars                      = var.lambdas.poll_handler.env_vars
      memory_size                   = var.lambdas.poll_handler.memory_size
      timeout                       = var.lambdas.poll_handler.timeout
      override_event_source_mapping = var.lambdas.poll_handler.override_event_source_mapping
      allowed_triggers              = local.common_lambda_permissions
    }

    query_handler = {
      env_vars                      = var.lambdas.query_handler.env_vars
      memory_size                   = var.lambdas.query_handler.memory_size
      timeout                       = var.lambdas.query_handler.timeout
      override_event_source_mapping = var.lambdas.query_handler.override_event_source_mapping
      allowed_triggers              = local.common_lambda_permissions
    }

    lift_processing_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          SQS_TX_QUEUE_URL = module.sqs_queues[var.sqs.tx_queue_name].queue_url
        }, var.lambdas.lift_processing_handler.env_vars
      ) : var.lambdas.lift_processing_handler.env_vars

      memory_size                   = var.lambdas.lift_processing_handler.memory_size
      timeout                       = var.lambdas.lift_processing_handler.timeout
      override_event_source_mapping = var.lambdas.lift_processing_handler.override_event_source_mapping
      extra_policy_arn              = aws_iam_policy.gateway_lift_processing_access.arn
      allowed_triggers = merge(
        local.common_lambda_permissions,
        {
          allow_event_bridge_rule = {
            principal  = "events.amazonaws.com"
            source_arn = module.eventbridge.eventbridge_rule_arns["lift_processing_handler"]
          }
        }
      )
    }

    tx_status_update_handler = {
      env_vars                      = var.lambdas.tx_status_update_handler.env_vars
      memory_size                   = var.lambdas.tx_status_update_handler.memory_size
      timeout                       = var.lambdas.tx_status_update_handler.timeout
      override_event_source_mapping = var.lambdas.tx_status_update_handler.override_event_source_mapping
      allowed_triggers = merge(
        local.common_lambda_permissions,
        {
          allow_event_bridge_rule = {
            principal  = "events.amazonaws.com"
            source_arn = module.eventbridge.eventbridge_rule_arns["tx_status_update_handler"]
          }
        }
      )
    }

    vote_handler = {
      env_vars                      = var.lambdas.vote_handler.env_vars
      memory_size                   = var.lambdas.vote_handler.memory_size
      timeout                       = var.lambdas.vote_handler.timeout
      override_event_source_mapping = var.lambdas.vote_handler.override_event_source_mapping
      extra_policy_arn              = aws_iam_policy.gateway_vote_access.arn
      allowed_triggers              = local.common_lambda_permissions
    }

    lower_handler = {
      env_vars                      = var.lambdas.lower_handler.env_vars
      memory_size                   = var.lambdas.lower_handler.memory_size
      timeout                       = var.lambdas.lower_handler.timeout
      override_event_source_mapping = var.lambdas.lower_handler.override_event_source_mapping
      allowed_triggers              = local.common_lambda_permissions
    }

    split_fee_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          SQS_DEFAULT_QUEUE_URL = module.sqs_queues[var.sqs.default_queue_name].queue_url
          SQS_PAYER_QUEUE_URL   = module.sqs_queues[var.sqs.payer_queue_name].queue_url
        }, var.lambdas.split_fee_handler.env_vars
      ) : var.lambdas.split_fee_handler.env_vars

      event_source_mapping = coalesce(var.lambdas.split_fee_handler.override_event_source_mapping, {
        sqs_payer = {
          event_source_arn        = module.sqs_queues[var.sqs.payer_queue_name].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      })

      memory_size      = var.lambdas.split_fee_handler.memory_size
      timeout          = var.lambdas.split_fee_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_split_fee_access.arn
      allowed_triggers = local.common_lambda_permissions
    }

    tx_dispatch_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          SQS_DEFAULT_QUEUE_URL = module.sqs_queues[var.sqs.default_queue_name].queue_url
          SQS_TX_QUEUE_URL      = module.sqs_queues[var.sqs.tx_queue_name].queue_url
        }, var.lambdas.tx_dispatch_handler.env_vars
      ) : var.lambdas.tx_dispatch_handler.env_vars

      event_source_mapping = coalesce(var.lambdas.tx_dispatch_handler.override_event_source_mapping, {
        sqs_default = {
          event_source_arn        = module.sqs_queues[var.sqs.default_queue_name].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      })
      memory_size      = var.lambdas.tx_dispatch_handler.memory_size
      timeout          = var.lambdas.tx_dispatch_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_tx_dispatch_access.arn
      allowed_triggers = local.common_lambda_permissions
    }

    webhooks_event_emitter_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          WEBHOOKS_SIGNER_KMS_KEY_ID = aws_kms_key.gateway_webhooks.key_id
        },
        var.lambdas.webhooks_event_emitter_handler.env_vars
      ) : var.lambdas.webhooks_event_emitter_handler.env_vars
      memory_size      = var.lambdas.webhooks_event_emitter_handler.memory_size
      timeout          = var.lambdas.webhooks_event_emitter_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_webhooks_event_emitter_access.arn
      allowed_triggers = {
        sqs_webhooks_event_emitter = {
          principal  = "sqs.amazonaws.com"
          source_arn = module.sqs_queues[var.sqs.webhooks_queue_name].queue_arn
        }
      }
      event_source_mapping = {
        sqs_webhooks = {
          event_source_arn        = module.sqs_queues[var.sqs.webhooks_queue_name].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      }
    }

    webhooks_verification_key_handler = {
      env_vars = var.lambdas.extra_envs ? merge(
        {
          WEBHOOKS_SIGNER_KMS_KEY_ID = aws_kms_key.gateway_webhooks.key_id
        },
        var.lambdas.webhooks_verification_key_handler.env_vars
      ) : var.lambdas.webhooks_verification_key_handler.env_vars
      memory_size      = var.lambdas.webhooks_verification_key_handler.memory_size
      timeout          = var.lambdas.webhooks_verification_key_handler.timeout
      allowed_triggers = local.common_lambda_permissions
      extra_policy_arn = aws_iam_policy.gateway_webhooks_verification_key_access.arn
    }

    invalid_transaction_handler = {
      env_vars = var.lambdas.invalid_transaction_handler.env_vars
      event_source_mapping = coalesce(var.lambdas.invalid_transaction_handler.override_event_source_mapping, {
        sqs_default = {
          event_source_arn = module.sqs_queues[var.sqs.default_queue_name].dead_letter_queue_arn
        }
        sqs_payer = {
          event_source_arn = module.sqs_queues[var.sqs.payer_queue_name].dead_letter_queue_arn
        }
      })

      memory_size      = var.lambdas.invalid_transaction_handler.memory_size
      timeout          = var.lambdas.invalid_transaction_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_invalid_transaction_access.arn
      allowed_triggers = local.common_lambda_permissions
    }
  }

  common_lambda_permissions = {
    allow_api_gateway = {
      statement_id = "AllowAPIgatewayInvocation"
      service      = "apigateway"
      source_arn   = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${module.api_gateway.api_id}/*"
    }
  }

  defaults_cognito_user_groups = [
    {
      name        = "admin",
      description = "Group to grant admin permission to users of the admin portal."
    },
    {
      name        = "ops",
      description = "Group for users who maintain the infra and infra level configurations."
    },
    {
      name        = "payer",
      description = "Group for payers of the AvN Gateway."
    },
    {
      name        = "read",
      description = "Group to grant read permission to users of the admin portal."
    },
    {
      name        = "relayer",
      description = "Group for relayers of the AvN Gateway."
    },
    {
      name        = "write",
      description = "Group to grant write permission to users of the admin portal."
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
}
