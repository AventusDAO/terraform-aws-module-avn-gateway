output "rds" {
  description = "RDS outputs"
  value = tomap({
    "db_instance_identifier" = try(module.rds[0].db_instance_identifier, null)
  })
}

output "dns_settings" {
  description = "DNS Settings for API Gateway and Admin Portal"
  value = tomap({
    api_gateway = {
      for k, v in var.api_gateway.domains : k => {
        name               = try(v.domain_name, null)
        hosted_zone_id     = try(aws_apigatewayv2_domain_name.this[k].hosted_zone_id, null)
        target_domain_name = try(aws_apigatewayv2_domain_name.this[k].target_domain_name, null)
      }
    }
    admin_portal = {
      name               = try(aws_cognito_user_pool_domain.admin_portal.domain, null)
      hosted_zone_id     = "Z2FDTNDATAQYW2" # This zone_id is fixed (cloudfront distribution)
      target_domain_name = try(aws_cognito_user_pool_domain.admin_portal.cloudfront_distribution_arn, null)
    }
  })
}
