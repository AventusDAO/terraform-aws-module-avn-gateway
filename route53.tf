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
