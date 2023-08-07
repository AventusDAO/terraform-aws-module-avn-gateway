#
# gateway lambdas policies
#
resource "aws_iam_policy" "gateway_send_handler_access" {
  name        = "${var.name}-send-handler-access"
  description = "allow send handler to send messages to SQS and read SM"
  policy      = var.lambdas.send_handler.extra_policy_document != null ? data.aws_iam_policy_document.gateway_send_handler_access_merged[0].json : data.aws_iam_policy_document.gateway_send_handler_access.json
}

resource "aws_iam_policy" "gateway_split_fee_access" {
  name        = "${var.name}-split-fee-handler-access"
  description = "spit fee access to SQS and SM"
  policy      = var.lambdas.split_fee_handler.extra_policy_document != null ? data.aws_iam_policy_document.gateway_split_fee_access_merged[0].json : data.aws_iam_policy_document.gateway_split_fee_access.json
}

resource "aws_iam_policy" "gateway_tx_dispatch_access" {
  name        = "${var.name}-tx-dispatch-handler-access"
  description = "allow access to SQS and SM"
  policy      = var.lambdas.tx_dispatch_handler.extra_policy_document != null ? data.aws_iam_policy_document.gateway_tx_dispatch_merged[0].json : data.aws_iam_policy_document.gateway_tx_dispatch_access.json
}

resource "aws_iam_policy" "gateway_invalid_transaction_access" {
  name        = "${var.name}-invalid-transaction-handler-access"
  description = "allow access to SQS and SM"
  policy      = var.lambdas.invalid_transaction_handler.extra_policy_document != null ? data.aws_iam_policy_document.gateway_invalid_transaction_access_merged[0].json : data.aws_iam_policy_document.gateway_invalid_transaction_access.json
}

resource "aws_iam_policy" "gateway_vote_access" {
  count = var.lambdas.vote_handler.vote_bucket != null ? 1 : 0

  name        = "${var.name}-vote-handler-access"
  description = "allow access to vote s3 bucket"
  policy      = data.aws_iam_policy_document.gateway_vote_access[0].json
}
