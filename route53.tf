#
# gateway cognito custom record
#
resource "aws_route53_record" "admin_portal" {
  count = var.cognito.create_dns_record ? 1 : 0

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
