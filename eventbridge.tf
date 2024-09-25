module "eventbridge" {
  source  = "terraform-aws-modules/eventbridge/aws"
  version = "3.2.3"

  create_bus = false

  rules = {
    tx_status_update_handler = {
      description         = "Job to update transaction state by checking block indexer resolve-pending-transactions"
      schedule_expression = "rate(1 minute)"
      state               = var.eventbridge_rules.tx_status_update_state
    }
    lift_processing_handler = {
      description         = "process-lifts trigger lambda lift_processing_handler"
      schedule_expression = "rate(3 minutes)"
      state               = var.eventbridge_rules.tx_status_update_state
    }
  }

  targets = {
    tx_status_update_handler = [
      {
        name = "tx_status_update_handler"
        arn  = module.lambdas["tx_status_update_handler"].lambda_function_arn
      }
    ]
    lift_processing_handler = [
      {
        name = "lift_processing_handler"
        arn  = module.lambdas["lift_processing_handler"].lambda_function_arn
      }
    ]
  }
}
