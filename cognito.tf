#
# gateway cognito pool and app
#

# for now, the email used to send the temp password to users will be no-reply@verificationemail.com
# This is limited to 50emails/day and aws recommend to use AMAZON SES
resource "aws_cognito_user_pool" "admin_portal" {
  name = "${lookup(var.cognito, "override_name", var.name)}-admin-portal"

  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = var.cognito.recovery_mechanism ? { for idx, mechanism in var.cognito.recovery_mechanism : idx => mechanism } : [{ 1 = "verified_email" }]
      content {
        name     = recovery_mechanism.value
        priority = recovery_mechanism.key + 1
      }
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = lookup(var.cognito, "allow_admin_create_user_only", true)

    invite_message_template {
      email_message = <<EOT
    <h3>Welcome to the ${title(replace(var.name, "-", " "))}</h3>
    <p>You have successfully registered as a payer on the ${title(replace(var.name, "-", " "))}.</p>
    Your username is <b>{username}</b> and temporary password is <b>{####}</b>
    <p>You will be prompted to change your password when you first log in, this password will expire in 1 day.</p>
EOT
      email_subject = "${title(replace(var.name, "-", " "))} registration - your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = lookup(var.cognito.password_policy, "minimum_length", 12)
    require_lowercase                = lookup(var.cognito.password_policy, "require_lowercase", true)
    require_numbers                  = lookup(var.cognito.password_policy, "require_numbers", true)
    require_symbols                  = lookup(var.cognito.password_policy, "require_symbols", true)
    require_uppercase                = lookup(var.cognito.password_policy, "require_uppercase", true)
    temporary_password_validity_days = lookup(var.cognito.password_policy, "temporary_password_validity_days", 1)
  }

  software_token_mfa_configuration {
    enabled = lookup(var.cognito, "software_token_mfa_configuration", true)
  }

  user_pool_add_ons {
    advanced_security_mode = lookup(var.cognito, "user_pool_add_ons", "OFF")
  }

  device_configuration {
    challenge_required_on_new_device      = lookup(var.cognito.device_configuration, "challenge_required_on_new_device", true)
    device_only_remembered_on_user_prompt = lookup(var.cognito.device_configuration, "device_only_remembered_on_user_prompt", true)
  }

  deletion_protection = lookup(var.cognito, "deletion_protection", "ACTIVE")
  mfa_configuration   = lookup(var.cognito, "mfa_configuration", "OPTIONAL")
  username_attributes = lookup(var.cognito, "username_attributes", ["email"])

  tags = merge(var.cognito.tags, { Name = lookup(var.cognito, "override_name", var.name) })
}

resource "aws_cognito_user_pool_domain" "admin_portal" {
  domain          = var.cognito.domain
  certificate_arn = var.cognito.certificate_arn
  user_pool_id    = aws_cognito_user_pool.admin_portal.id
}

resource "aws_cognito_user_pool_client" "admin_portal" {
  name                                 = "${lookup(var.cognito, "override_name", var.name)}-admin-portal"
  user_pool_id                         = aws_cognito_user_pool.admin_portal.id
  generate_secret                      = lookup(var.cognito.pool_client, "generate_secret", true)
  allowed_oauth_flows_user_pool_client = lookup(var.cognito.pool_client, "allowed_oauth_flows_user_pool_client", true)
  allowed_oauth_flows                  = lookup(var.cognito.pool_client, "allowed_oauth_flows", ["code"])
  explicit_auth_flows                  = lookup(var.cognito.pool_client, "explicit_auth_flows", ["ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"])
  allowed_oauth_scopes                 = lookup(var.cognito.pool_client, "allowed_oauth_scopes", ["email", "openid"])
  callback_urls                        = var.cognito.pool_client.callback_urls
  logout_urls                          = var.cognito.pool_client.logout_urls
  prevent_user_existence_errors        = lookup(var.cognito.pool_client, "prevent_user_existence_errors", "ENABLED")
  supported_identity_providers         = lookup(var.cognito.pool_client, "supported_identity_providers", ["COGNITO"])
}