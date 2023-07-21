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
    username = ""
    password = ""
    server   = ""
  }

  # lambdas
  lambda_layers = toset(["common", "queue"])

  lambdas = {
    authorisation_handler = {
      env_vars    = var.lambdas.authorisation_handler.env_vars
      memory_size = var.lambdas.authorisation_handler.memory_size
      timeout     = var.lambdas.authorisation_handler.timeout
    }

    send_handler = {
      env_vars = merge(var.lambdas.send_handler.env_vars,
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL   = module.sqs_queues["${var.name}_default_queue"].queue_url
          SQS_PAYER_QUEUE_URL     = module.sqs_queues["${var.name}_payer_queue"].queue_url
        }
      )
      memory_size      = var.lambdas.send_handler.memory_size
      timeout          = var.lambdas.send_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_send_handler_access.arn
    }

    poll_handler = {
      env_vars    = var.lambdas.poll_handler.env_vars
      memory_size = var.lambdas.poll_handler.memory_size
      timeout     = var.lambdas.poll_handler.timeout
    }

    query_handler = {
      env_vars    = var.lambdas.query_handler.env_vars
      memory_size = var.lambdas.query_handler.memory_size
      timeout     = var.lambdas.query_handler.timeout
    }

    lift_processing_handler = {
      env_vars = merge(var.lambdas.lift_processing_handler.env_vars,
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
        }
      )
      memory_size = var.lambdas.lift_processing_handler.memory_size
      timeout     = var.lambdas.lift_processing_handler.timeout
    }

    tx_status_update_handler = {
      env_vars    = var.lambdas.tx_status_update_handler.env_vars
      memory_size = var.lambdas.tx_status_update_handler.memory_size
      timeout     = var.lambdas.tx_status_update_handler.timeout
    }

    vote_handler = {
      env_vars    = var.lambdas.vote_handler.env_vars
      memory_size = var.lambdas.vote_handler.memory_size
      timeout     = var.lambdas.vote_handler.timeout
    }

    lower_handler = {
      env_vars    = var.lambdas.lower_handler.env_vars
      memory_size = var.lambdas.vote_handler.memory_size
      timeout     = var.lambdas.vote_handler.timeout
    }

    split_fee_handler = {
      env_vars = merge(var.lambdas.split_fee_handler.env_vars,
        {
          SECRET_MANAGER_REGION = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL = module.sqs_queues["${var.name}_default_queue"].queue_url
          SQS_PAYER_QUEUE_URL   = module.sqs_queues["${var.name}_payer_queue"].queue_url
        }
      )
      event_source_mapping = {
        sqs_payer = {
          event_source_arn        = module.sqs_queues["${var.name}_payer_queue"].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      }
      memory_size      = var.lambdas.split_fee_handler.memory_size
      timeout          = var.lambdas.split_fee_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_split_fee_access.arn
    }

    tx_dispatch_handler = {
      env_vars = merge(var.lambdas.tx_dispatch_handler.env_vars,
        {
          MQ_BROKER_AMQP_ENDPOINT = module.amazonmq.primary_amqp_ssl_endpoint
          MQ_SECRET_ARN           = aws_secretsmanager_secret.amazonmq.arn
          SECRET_MANAGER_REGION   = data.aws_region.current.name
          SQS_DEFAULT_QUEUE_URL   = module.sqs_queues["${var.name}_default_queue"].queue_url
      })
      event_source_mapping = {
        sqs_default = {
          event_source_arn        = module.sqs_queues["${var.name}_default_queue"].queue_arn
          function_response_types = ["ReportBatchItemFailures"]
        }
      }
      memory_size      = var.lambdas.tx_dispatch_handler.memory_size
      timeout          = var.lambdas.tx_dispatch_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_tx_dispatch_access.arn
    }

    invalid_transaction_handler = {
      env_vars = var.lambdas.invalid_transaction_handler.env_vars

      event_source_mapping = {
        sqs_default = {
          event_source_arn = module.sqs_queues["${var.name}_default_queue"].queue_arn
        }
        sqs_payer = {
          event_source_arn = module.sqs_queues["${var.name}_default_queue"].queue_arn
        }
      }

      memory_size      = var.lambdas.invalid_transaction_handler.memory_size
      timeout          = var.lambdas.invalid_transaction_handler.timeout
      extra_policy_arn = aws_iam_policy.gateway_invalid_transaction_access.arn
    }
  }
}
