module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.2.3"

  create_bus = false

  rules = {
    tx_status_update_handler = {
      description         = "trigger lambda tx_status_update_handler"
      schedule_expression = "rate(1 minutes)"
    }
    lift_processing_handler = {
      description         = "trigger lambda lift_processing_handler"
      schedule_expression = "rate(10 minutes)"
    }
  }

  targets = {
    tx_status_update_handler = [
      {
        name = "tx-status-update cron"
        arn  = module.lambdas["poll_handler"].lambda_function_invoke_arn
      }
    ]
    lift_processing_handler = [
      {
        name = "lift-processing cron"
        arn  = module.lambdas["lift_processing_handler"].lambda_function_invoke_arn
      }
    ]
  }
}
