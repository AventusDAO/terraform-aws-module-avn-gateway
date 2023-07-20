#
# gateway lambdas policies
#
resource "aws_iam_policy" "gateway_send_handler_access" {
  name        = "${var.name}-send-handler-access"
  description = "allow send handler to send messages to SQS and read SM"
  policy      = data.aws_iam_policy_document.gateway_send_handler_access.json
}

resource "aws_iam_policy" "gateway_split_fee_access" {
  name        = "${var.name}-split-fee-handler-access"
  description = "spit fee access to SQS and SM"
  policy      = data.aws_iam_policy_document.gateway_split_fee_access.json
}

resource "aws_iam_policy" "gateway_tx_dispatch_access" {
  name        = "${var.name}-tx-dispatch-handler-access"
  description = "allow access to SQS and SM"
  policy      = data.aws_iam_policy_document.gateway_tx_dispatch_access.json
}

resource "aws_iam_policy" "gateway_invalid_transaction_access" {
  name        = "${var.name}-invalid-transaction-handler-access"
  description = "allow access to SQS and SM"
  policy      = data.aws_iam_policy_document.gateway_invalid_transaction_access.json
}