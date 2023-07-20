locals {
  # secrets
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
    gateway_rds_host          = module.rds.db_instance_address
    gateway_app_schema_sync   = false
  }

  amazonmq_secrets = {
    username    = ""
    password    = ""
    admin_user  = ""
    admin_passw = ""
    server      = module.amazonmq.primary_amqp_ssl_endpoint
  }

  # lambdas
  lambda_layers = toset(["common", "queue"])

  lambdas = {
    authorisation_handler = {
      env_vars = lookup(var.lambdas.authorisation_handler, "env_vars",
        {
          MAX_TOKEN_AGE_MSEC = 600000
          MIN_AVT_BALANCE    = "1000000000000000000"
        }
      )
      memory_size = lookup(var.lambdas.authorisation_handler, "memory_size", 512)
      timeout     = lookup(var.lambdas.authorisation_handler, "timeout", 30)
    }

    send_handler = {
      env_vars = merge(lookup(var.lambdas.send_handler, "env_vars",
        {
          MQ_AVN_TX_QUEUE = "avnTx"
        }),
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL   = module.sqs_queues["gateway_default_queue"].queue_url
          SQS_PAYER_QUEUE_URL     = module.sqs_queues["gateway_payer_queue"].queue_url
        }
      )
      memory_size      = lookup(var.lambdas.send_handler, "memory_size", 512)
      timeout          = lookup(var.lambdas.send_handler, "timeout", 30)
      extra_policy_arn = aws_iam_policy.gateway_send_handler_access.arn
    }

    poll_handler = {
      env_vars    = (lookup(var.lambdas.poll_handler, "env_vars", {}))
      memory_size = lookup(var.lambdas.poll_handler, "memory_size", 256)
      timeout     = lookup(var.lambdas.poll_handler, "timeout", 30)
    }

    query_handler = {
      env_vars    = (lookup(var.lambdas.query_handler, "env_vars", {}))
      memory_size = lookup(var.lambdas.query_handler, "memory_size", 256)
      timeout     = lookup(var.lambdas.query_handler, "timeout", 30)
    }

    lift_processing_handler = {
      env_vars = merge(lookup(var.lambdas.lift_processing_handler, "env_vars",
        {
          MQ_AVN_TX_QUEUE = "avnTx"
        }),
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
        }
      )
      memory_size = lookup(var.lambdas.lift_processing_handler, "memory_size", 128)
      timeout     = lookup(var.lambdas.lift_processing_handler, "timeout", 30)
    }

    tx_status_update_handler = {
      env_vars    = (lookup(var.lambdas.tx_status_update_handler, "env_vars", {}))
      memory_size = lookup(var.lambdas.tx_status_update_handler, "memory_size", 256)
      timeout     = lookup(var.lambdas.tx_status_update_handler, "timeout", 30)
    }

    vote_handler = {
      env_vars    = (lookup(var.lambdas.vote_handler, "env_vars", {}))
      memory_size = lookup(var.lambdas.vote_handler, "memory_size", 256)
      timeout     = lookup(var.lambdas.vote_handler, "timeout", 30)
    }

    lower_handler = {
      env_vars    = (lookup(var.lambdas.lower_handler, "env_vars", {}))
      memory_size = lookup(var.lambdas.vote_handler, "memory_size", 256)
      timeout     = lookup(var.lambdas.vote_handler, "timeout", 30)
    }

    split_fee_handler = {
      env_vars = merge(lookup(var.lambdas.split_fee_handler, "env_vars", {}),
        {
          SECRET_MANAGER_REGION = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL = module.sqs_queues["gateway_default_queue"].queue_url
          SQS_PAYER_QUEUE_URL   = module.sqs_queues["gateway_payer_queue"].queue_url
        }
      )
      event_source_mapping = {
        sqs_payer = {
          event_source_arn        = module.sqs_queues["gateway_payer_queue"].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      }
      memory_size      = lookup(var.lambdas.split_fee_handler, "memory_size", 512)
      timeout          = lookup(var.lambdas.split_fee_handler, "timeout", 30)
      extra_policy_arn = aws_iam_policy.gateway_split_fee_access.arn
    }

    tx_dispatch_handler = {
      env_vars = merge(lookup(var.lambdas.tx_dispatch_handler, "env_vars",
        {
          MQ_AVN_TX_QUEUE = "avnTx"
        }),
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL   = module.sqs_queues["gateway_default_queue"].queue_url
      })
      event_source_mapping = {
        sqs_default = {
          event_source_arn        = module.sqs_queues["gateway_default_queue"].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      }
      memory_size      = lookup(var.lambdas.tx_dispatch_handler, "memory_size", 512)
      timeout          = lookup(var.lambdas.tx_dispatch_handler, "timeout", 30)
      extra_policy_arn = aws_iam_policy.gateway_tx_dispatch_access.arn
    }

    invalid_transaction_handler = {
      env_vars = (lookup(var.lambdas.invalid_transaction_handler, "env_vars", {}))

      event_source_mapping = {
        sqs_default = {
          event_source_arn = module.sqs_queues["gateway_default_queue"].queue_arn
        }
        sqs_payer = {
          event_source_arn = module.sqs_queues["gateway_default_queue"].queue_arn
        }
      }

      memory_size      = lookup(var.lambdas.invalid_transaction_handler, "memory_size", 512)
      timeout          = lookup(var.lambdas.invalid_transaction_handler, "timeout", 30)
      extra_policy_arn = aws_iam_policy.gateway_invalid_transaction_access.arn
    }
  }
}