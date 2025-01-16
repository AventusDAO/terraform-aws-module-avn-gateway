#
# gateway cognito custom record
#
resource "aws_route53_record" "admin_portal" {
  count = var.cognito.create_dns_record ? 1 : 0

  zone_id         = var.cognito.route53_zone_id
  name            = aws_cognito_user_pool_domain.admin_portal.domain
  type            = "A"
  allow_overwrite = true

  alias {
    name                   = aws_cognito_user_pool_domain.admin_portal.cloudfront_distribution_arn
    evaluate_target_health = false
    # This zone_id is fixed (cloudfront distribution)
    zone_id = "Z2FDTNDATAQYW2"
  }
}

#
# API Gateway custom record
#
resource "aws_apigatewayv2_domain_name" "this" {
  for_each = var.api_gateway.domains

  domain_name = each.value.domain_name

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = var.api_gateway.tags
}

resource "aws_apigatewayv2_api_mapping" "this" {
  for_each = var.api_gateway.domains

  api_id      = module.api_gateway.api_id
  domain_name = aws_apigatewayv2_domain_name.this[each.key].id
  stage       = module.api_gateway.stage_id
}

resource "aws_route53_record" "api_gateway" {
  for_each = {
    for key, value in var.api_gateway.domains : key => value
    if value.create_dns_record
  }

  zone_id = each.value.route53_zone_id
  name    = each.value.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.this[each.key].domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.this[each.key].domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}
