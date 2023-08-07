data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "current" {
  id = var.vpc_id
}

#
# Gateway SM
#
data "aws_secretsmanager_secret_version" "amazonmq" {
  secret_id = aws_secretsmanager_secret.amazonmq.id

  depends_on = [aws_secretsmanager_secret_version.amazonmq]
}

#
# Gateway policies
#

# Send handler SQS access
data "aws_iam_policy_document" "gateway_send_handler_access" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      module.sqs_queues["${var.name}_default_queue"].queue_arn,
      module.sqs_queues["${var.name}_payer_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.amazonmq.arn
    ]
  }
}

data "aws_iam_policy_document" "gateway_send_handler_access_merged" {
  count = var.lambdas.send_handler.extra_policy_document ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.gateway_send_handler_access.json,
    var.lambdas.send_handler.extra_policy_document
  ]
}

# split-fee-handler SQS access
data "aws_iam_policy_document" "gateway_split_fee_access" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
    ]
    resources = [
      module.sqs_queues["${var.name}_payer_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      module.sqs_queues["${var.name}_default_queue"].queue_arn
    ]
  }
}

data "aws_iam_policy_document" "gateway_split_fee_access_merged" {
  count = var.lambdas.split_fee_handler.extra_policy_document ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.gateway_split_fee_access.json,
    var.lambdas.split_fee_handler.extra_policy_document
  ]
}

# tx-dispatch-handler SQS access
data "aws_iam_policy_document" "gateway_tx_dispatch_access" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes",
    ]
    resources = [
      module.sqs_queues["${var.name}_default_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.amazonmq.arn
    ]
  }
}

data "aws_iam_policy_document" "gateway_tx_dispatch_merged" {
  count = var.lambdas.tx_dispatch_handler.extra_policy_document ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.gateway_tx_dispatch_access.json,
    var.lambdas.tx_dispatch_handler.extra_policy_document
  ]
}

# invalid-transaction-handler DLQ access
data "aws_iam_policy_document" "gateway_invalid_transaction_access" {
  statement {
    effect = "Allow"
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:DeleteMessageBatch",
      "sqs:GetQueueAttributes"
    ]
    resources = [
      module.sqs_queues["${var.name}_default_queue"].dead_letter_queue_arn,
      module.sqs_queues["${var.name}_payer_queue"].dead_letter_queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.amazonmq.arn
    ]
  }
}

data "aws_iam_policy_document" "gateway_invalid_transaction_access_merged" {
  count = var.lambdas.invalid_transaction_handler.extra_policy_document ? 1 : 0

  source_policy_documents = [
    data.aws_iam_policy_document.gateway_tx_dispatch_access.json,
    var.lambdas.invalid_transaction_handler.extra_policy_document
  ]
}

# gateway-admin-portal
data "aws_iam_policy_document" "gateway_admin_portal" {
  statement {
    effect = "Allow"
    actions = [
      "cognito-idp:AdminCreateUser",
      "cognito-idp:AdminGetUser",
    ]
    resources = [
      "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${aws_cognito_user_pool_domain.admin_portal.id}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.cognito.arn,
      aws_secretsmanager_secret.rds.arn,
      aws_secretsmanager_secret.vault.arn
    ]
  }
}

#
# gateway vault SA
#
data "aws_iam_policy_document" "gateway_vault" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:DescribeKey",
    ]
    resources = [aws_kms_key.gateway_vault.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.vault.arn
    ]
  }
}

#
# gateway connector SA
#
data "aws_iam_policy_document" "gateway_connector" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      aws_secretsmanager_secret.amazonmq.arn,
      aws_secretsmanager_secret.rds.arn,
      aws_secretsmanager_secret.vault.arn,
      aws_secretsmanager_secret.connector.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.lambdas["tx_status_update_handler"].lambda_function_qualified_arn,
      module.lambdas["tx_status_update_handler"].lambda_function_qualified_arn
    ]
  }
}
