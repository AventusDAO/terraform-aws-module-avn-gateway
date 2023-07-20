#
# api-gateway
#
module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "2.2.2"

  name          = coalesce(var.api_gateway.override_name, var.name)
  description   = coalesce(var.api_gateway.description, "API Gateway for the ${replace(coalesce(var.api_gateway.override_name, var.name), "-", " ")}")
  protocol_type = var.api_gateway.protocol_type

  cors_configuration = {
    allow_credentials = lookup(var.api_gateway.cors_configuration, "allow_credentials", false)
    allow_headers     = lookup(var.api_gateway.cors_configuration, "allow_headers", ["*"])
    allow_methods     = lookup(var.api_gateway.cors_configuration, "allow_methods", ["*"])
    allow_origins     = lookup(var.api_gateway.cors_configuration, "allow_origins", ["*"])
    expose_headers    = lookup(var.api_gateway.cors_configuration, "expose_headers", ["*"])
    max_age           = lookup(var.api_gateway.cors_configuration, "max_age", 100)
  }

  # Custom domain
  domain_name                 = "${coalesce(var.api_gateway.override_name, var.name)}.${var.api_gateway.domain_name_suffix}"
  domain_name_certificate_arn = var.api_gateway.domain_name_certificate_arn

  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.api_gateway.arn

  default_stage_access_log_format = coalesce(var.api_gateway.default_stage_access_log_format,
    jsonencode(
      {
        httpMethod     = "$context.httpMethod"
        ip             = "$context.identity.sourceIp"
        protocol       = "$context.protocol"
        requestId      = "$context.requestId"
        requestTime    = "$context.requestTime"
        responseLength = "$context.responseLength"
        routeKey       = "$context.routeKey"
        status         = "$context.status"
      }
    )
  )

  default_route_settings = {
    detailed_metrics_enabled = lookup(var.api_gateway.default_route_settings, "detailed_metrics_enabled", true)
    throttling_burst_limit   = lookup(var.api_gateway.default_route_settings, "throttling_burst_limit", 100)
    throttling_rate_limit    = lookup(var.api_gateway.default_route_settings, "throttling_burst_limit", 100)
  }

  authorizers = {
    "authorisation_handler_lambda" = {
      authorizer_type                   = "REQUEST"
      identity_sources                  = "$request.header.Authorization"
      name                              = "authorisation-handler"
      authorizer_uri                    = module.lambdas["authorisation_handler"].lambda_function_qualified_invoke_arn
      enable_simple_responses           = true
      authorizer_result_ttl_in_seconds  = 300
      authorizer_payload_format_version = "2.0"
    }
  }

  # Routes and integrations
  integrations = {
    "POST /poll" = {
      authorizer_key         = "authorisation_handler_lambda"
      authorization_type     = "CUSTOM"
      integration_type       = "AWS_PROXY"
      description            = "Poll handler integration"
      integration_method     = "POST"
      integration_uri        = module.lambdas["poll_handler"].lambda_function_qualified_invoke_arn
      passthrough_behavior   = "WHEN_NO_MATCH"
      payload_format_version = "2.0"
    }

    "POST /send" = {
      authorizer_key         = "authorisation_handler_lambda"
      authorization_type     = "CUSTOM"
      integration_type       = "AWS_PROXY"
      connection_type        = "INTERNET"
      description            = "Send handler integration"
      integration_method     = "POST"
      integration_uri        = module.lambdas["send_handler"].lambda_function_qualified_invoke_arn
      passthrough_behavior   = "WHEN_NO_MATCH"
      payload_format_version = "2.0"
    }

    "POST /query" = {
      authorizer_key         = "authorisation_handler_lambda"
      authorization_type     = "CUSTOM"
      integration_type       = "AWS_PROXY"
      connection_type        = "INTERNET"
      description            = "Query handler integration"
      integration_method     = "POST"
      integration_uri        = module.lambdas["query_handler"].lambda_function_qualified_invoke_arn
      passthrough_behavior   = "WHEN_NO_MATCH"
      payload_format_version = "2.0"
    }

    "ANY /vote" = {
      integration_type       = "AWS_PROXY"
      connection_type        = "INTERNET"
      description            = "Vote handler integration"
      integration_method     = "POST"
      integration_uri        = module.lambdas["vote_handler"].lambda_function_qualified_invoke_arn
      passthrough_behavior   = "WHEN_NO_MATCH"
      payload_format_version = "2.0"
    }

    "GET /lower" = {
      integration_type       = "AWS_PROXY"
      connection_type        = "INTERNET"
      description            = "Lower handler integration"
      integration_method     = "POST"
      integration_uri        = module.lambdas["lower_handler"].lambda_function_qualified_invoke_arn
      passthrough_behavior   = "WHEN_NO_MATCH"
      payload_format_version = "2.0"
    }
  }

  tags = merge(var.api_gateway.tags, { Name = coalesce(var.api_gateway.override_name, var.name) })
}

#
# gateway api gateway log group
#
resource "aws_cloudwatch_log_group" "api_gateway" {
  name              = coalesce(var.api_gateway.override_name, var.name)
  retention_in_days = var.api_gateway.retention_in_days
}
