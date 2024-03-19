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
        name = "tx_status_update_handler"
        arn  = module.lambdas["tx_status_update_handler"].lambda_function_invoke_arn
      }
    ]
    lift_processing_handler = [
      {
        name = "lift_processing_handler"
        arn  = module.lambdas["lift_processing_handler"].lambda_function_invoke_arn
      }
    ]
  }
}
