#
# gateway lambdas layers
#
module "lambdas_layers" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "5.3.0"

  create_layer        = true
  layer_name          = each.key
  description         = "${each.key} - ${var.lambda_version} - Deployed by Terraform"
  compatible_runtimes = lookup(var.lambdas, "layer_compatible_runtimes", ["nodejs14.x"])
  create_package      = false

  s3_existing_package = {
    bucket = lookup(var.lambdas.zip_location, "bucket", "aventus-internal-artefact")
    key    = "${lookup(var.lambdas.zip_location, "key_prefix", "gateway-lambdas")}/${each.key}/${each.key}-${var.lambda_version}.zip"
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

  function_name = each.key
  description   = "${each.key} - ${var.lambda_version} - Deployed by Terraform"
  publish       = true

  handler                           = "${each.key}.handler"
  runtime                           = lookup(var.lambdas, "runtime", "nodejs14.x")
  environment_variables             = merge(lookup(each.value, "env_vars", {}), lookup(var.lambdas, "common_env_vars", {}))
  timeout                           = each.value.timeout
  memory_size                       = each.value.memory_size
  layers                            = [for layer in module.lambdas_layers : layer.lambda_layer_arn]
  cloudwatch_logs_retention_in_days = lookup(var.lambdas, "cloudwatch_logs_retention_in_days", 14)

  allowed_triggers = {
    allow_api_gateway = {
      statement_id = "AllowAPIgatewayInvocation"
      principal    = "apigateway.amazonaws.com"
      source_arn   = module.api_gateway.apigatewayv2_api_arn
    }
  }

  event_source_mapping  = lookup(each.value, "event_source_mapping", {})
  attach_network_policy = true
  attach_policy         = contains(keys(each.value), "extra_policy_arn")
  policy                = lookup(each.value, "extra_policy_arn", null)
  create_package        = false

  s3_existing_package = {
    bucket = lookup(var.lambdas.zip_location, "bucket", "aventus-internal-artefact")
    key    = "${lookup(var.lambdas.zip_location, "key_prefix", "gateway-lambdas")}/${each.key}/${each.key}-${var.lambda_version}.zip"
  }

  for_each = local.lambdas
}
