#
# gateway: api-gateway record
#
resource "aws_route53_record" "api_gateway" {
  zone_id = var.route53_zone_id
  name    = coalesce(trimsuffix(var.api_gateway.custom_domain, ".gateway.aventus.io"))
  type    = "A"

  alias {
    name                   = module.api_gateway.apigatewayv2_domain_name_configuration[0].target_domain_name
    zone_id                = module.api_gateway.apigatewayv2_domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

#
# gateway cognito custom record
#
resource "aws_route53_record" "admin_portal" {
  zone_id         = var.route53_zone_id
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
