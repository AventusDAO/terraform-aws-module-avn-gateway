#
# gateway lambdas layers
#
module "lambdas_layers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.3.0"

  create_layer        = true
  layer_name          = "${replace(var.name, "-", "_")}_${each.key}"
  description         = "${replace(var.name, "-", "_")}_${each.key} - ${var.lambda_version} - Deployed by Terraform"
  compatible_runtimes = var.lambdas.layer_compatible_runtimes
  create_package      = false

  s3_existing_package = {
    bucket = var.lambdas.zip_location.bucket
    key    = "${var.lambdas.zip_location.key_prefix}/${replace(each.key, "_", "-")}/${replace(each.key, "_", "-")}-${var.lambda_version}.zip"
  }

  for_each = local.lambda_layers
}

#
# gateway lambdas
#
module "lambdas" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.3.0"

  vpc_subnet_ids         = var.lambdas.vpc_subnet_ids
  vpc_security_group_ids = [module.sg_lambdas.security_group_id]

  function_name = "${replace(var.name, "-", "_")}_${each.key}"
  description   = "${replace(var.name, "-", "_")}_${each.key} - ${var.lambda_version} - Deployed by Terraform"
  publish       = true

  handler                           = "${replace(var.name, "-", "_")}_${each.key}.handler"
  runtime                           = var.lambdas.runtime
  environment_variables             = merge(each.value.env_vars, var.lambdas.common_env_vars)
  timeout                           = each.value.timeout
  memory_size                       = each.value.memory_size
  layers                            = [for layer in module.lambdas_layers : layer.lambda_layer_arn]
  cloudwatch_logs_retention_in_days = var.lambdas.cloudwatch_logs_retention_in_days

  allowed_triggers = {
    allow_api_gateway = {
      statement_id = "AllowAPIgatewayInvocation"
      principal    = "apigateway.amazonaws.com"
      source_arn   = module.api_gateway.apigatewayv2_api_arn
    }
    allow_event_bridge_rule = each.value.cw_event_rule_id ? {
      statement_id = "AllowExecutionFromEventBridgeRule"
      principal    = "events.amazonaws.com"
      source_arn   = "arn:aws:events:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:rule/${each.value.cw_event_rule_id}"
    } : {}
  }

  event_source_mapping  = lookup(each.value, "event_source_mapping", {})
  attach_network_policy = true
  attach_policy         = contains(keys(each.value), "extra_policy_arn")
  policy                = lookup(each.value, "extra_policy_arn", null)
  create_package        = false

  s3_existing_package = {
    bucket = var.lambdas.zip_location.bucket
    key    = "${var.lambdas.zip_location.key_prefix}/${replace(each.key, "_", "-")}/${replace(each.key, "_", "-")}-${var.lambda_version}.zip"
  }

  for_each = local.lambdas
}

resource "aws_cloudwatch_event_target" "lambdas" {
  arn  = module.lambdas[each.key].lambda_function_arn
  rule = each.value.cw_event_rule_id

  for_each = { for k, v in local.lambdas : k => v if contains(keys(v), "cw_event_rule_id") }
}
