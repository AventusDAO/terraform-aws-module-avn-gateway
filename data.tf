data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_vpc" "current" {
  id = var.vpc_id
}

#
# Gateway SM
#
data "aws_secretsmanager_secret_version" "gateway_amazonmq" {
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
      module.sqs_queues["gateway_default_queue"].queue_arn,
      module.sqs_queues["gateway_payer_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.gateway_amazonmq.arn
    ]
  }
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
      module.gateway_sqs_queues["gateway_payer_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "sqs:SendMessage",
      "sqs:SendMessageBatch"
    ]
    resources = [
      module.gateway_sqs_queues["gateway_default_queue"].queue_arn
    ]
  }
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
      module.gateway_sqs_queues["gateway_default_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.gateway_amazonmq.arn
    ]
  }
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
      module.gateway_sqs_queues["gateway_default_queue"].queue_arn,
      module.gateway_sqs_queues["gateway_payer_queue"].queue_arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [
      aws_secretsmanager_secret.gateway_amazonmq.arn
    ]
  }
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
      "arn:aws:cognito-idp:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:userpool/${aws_cognito_user_pool_domain.gateway_admin_portal.id}"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
    ]
    resources = [
      aws_secretsmanager_secret.gateway_admin_portal.arn,
      aws_secretsmanager_secret.gateway_rds.arn
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
      aws_secretsmanager_secret.gateway_connector.arn
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = [
      module.gateway_lambdas["tx-status-update-handler"].lambda_function_qualified_arn,
      module.gateway_lambdas["tx-status-update-handler"].lambda_function_qualified_arn
    ]
  }
}
