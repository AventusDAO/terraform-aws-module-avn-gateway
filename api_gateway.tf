#
# api-gateway
#
module "api_gateway" {
  source  = "terraform-aws-modules/apigateway-v2/aws"
  version = "5.0.0"

  name          = coalesce(var.api_gateway.override_name, var.name)
  description   = coalesce(var.api_gateway.description, "API Gateway for the ${replace(coalesce(var.api_gateway.override_name, var.name), "-", " ")}")
  protocol_type = var.api_gateway.protocol_type

  cors_configuration = {
    allow_credentials = var.api_gateway.cors_configuration.allow_credentials
    allow_headers     = var.api_gateway.cors_configuration.allow_headers
    allow_methods     = var.api_gateway.cors_configuration.allow_methods
    allow_origins     = var.api_gateway.cors_configuration.allow_origins
    expose_headers    = var.api_gateway.cors_configuration.expose_headers
    max_age           = var.api_gateway.cors_configuration.max_age
  }

  # Custom domain
  domain_name                 = var.api_gateway.domain_name
  subdomains                  = var.api_gateway.subdomains
  domain_name_certificate_arn = var.api_gateway.domain_name_certificate_arn
  create_domain_records       = true
  create_certificate          = false

  # Access logs
  stage_access_log_settings = {
    create_log_group            = true
    log_group_name              = coalesce(var.api_gateway.override_name, var.name)
    log_group_retention_in_days = var.api_gateway.retention_in_days
    format = coalesce(var.api_gateway.default_stage_access_log_format,
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
  }

  stage_default_route_settings = {
    detailed_metrics_enabled = var.api_gateway.stage_default_route_settings.detailed_metrics_enabled
    throttling_burst_limit   = var.api_gateway.stage_default_route_settings.throttling_burst_limit
    throttling_rate_limit    = var.api_gateway.stage_default_route_settings.throttling_burst_limit
  }

  authorizers = {
    "authorisation_handler_lambda" = {
      authorizer_type                   = "REQUEST"
      identity_sources                  = ["$request.header.Authorization"]
      name                              = "authorisation-handler"
      authorizer_uri                    = module.lambdas["authorisation_handler"].lambda_function_invoke_arn
      enable_simple_responses           = true
      authorizer_result_ttl_in_seconds  = 300
      authorizer_payload_format_version = "2.0"
    }
  }

  # Routes and integrations
  routes = {
    "POST /poll" = {
      authorizer_key     = "authorisation_handler_lambda"
      authorization_type = "CUSTOM"

      integration = {
        description            = "Poll handler integration"
        method                 = "POST"
        uri                    = module.lambdas["poll_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
      }
    }

    "POST /send" = {
      authorizer_key     = "authorisation_handler_lambda"
      authorization_type = "CUSTOM"

      integration = {
        description            = "Send handler integration"
        method                 = "POST"
        uri                    = module.lambdas["send_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
        connection_type        = "INTERNET"
      }
    }

    "POST /query" = {
      authorizer_key         = "authorisation_handler_lambda"
      authorization_type     = "CUSTOM"
      throttling_rate_limit  = 500
      throttling_burst_limit = 400

      integration = {
        description            = "Query handler integration"
        method                 = "POST"
        uri                    = module.lambdas["query_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
        connection_type        = "INTERNET"
      }
    }

    "ANY /vote" = {
      integration = {
        description            = "Vote handler integration"
        method                 = "POST"
        uri                    = module.lambdas["vote_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
        connection_type        = "INTERNET"
      }
    }

    "GET /lowers" = {
      integration = {
        description            = "Lower handler integration"
        method                 = "POST"
        uri                    = module.lambdas["lower_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
        connection_type        = "INTERNET"
      }
    }

    "GET /verification/webhooks/signer-sha256-public" = {
      integration = {
        description            = "webhooks verification key handler"
        method                 = "POST"
        uri                    = module.lambdas["webhooks_verification_key_handler"].lambda_function_invoke_arn
        passthrough_behavior   = "WHEN_NO_MATCH"
        payload_format_version = "2.0"
        connection_type        = "INTERNET"
      }

    }
  }

  tags = merge(var.api_gateway.tags, { Name = coalesce(var.api_gateway.override_name, var.name) })
}

#TODO: delete all below after domain migration
resource "aws_apigatewayv2_domain_name" "api_gateway_deprecated" {
  domain_name = var.api_gateway.old_custom_domain

  domain_name_configuration {
    certificate_arn = var.api_gateway.old_domain_name_certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.api_gateway.tags
}

resource "aws_apigatewayv2_api_mapping" "this" {
  api_id      = module.api_gateway.api_id
  domain_name = module.api_gateway.domain_name_id
  stage       = module.api_gateway.stage_id
}

resource "aws_route53_record" "api_gateway" {
  zone_id = var.old_route53_zone_id
  name    = var.api_gateway.old_custom_domain
  type    = "A"

  alias {
    name                   = module.api_gateway.domain_name_target_domain_name
    zone_id                = module.api_gateway.domain_name_hosted_zone_id
    evaluate_target_health = false
  }
}
