#
# gateway cognito pool and app
#

# For now, the email used to send the temp password to users will be no-reply@verificationemail.com
# This is limited to 50emails/day and aws recommend to use AMAZON SES
resource "aws_cognito_user_pool" "admin_portal" {
  name = coalesce(var.cognito.override_name, "${var.name}-admin-portal")

  account_recovery_setting {
    dynamic "recovery_mechanism" {
      for_each = { for idx, mechanism in var.cognito.recovery_mechanism : idx => mechanism }
      content {
        name     = recovery_mechanism.value
        priority = recovery_mechanism.key + 1
      }
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = var.cognito.allow_admin_create_user_only

    invite_message_template {
      email_message = <<EOT
    <div style="font-family: Mona Sans,sans-serif;">
      <h3>Welcome to the ${title(replace(var.name, "-", " "))}</h3>
      <p>You have successfully registered on the ${title(replace(var.name, "-", " "))}.</p>
      Your username is <b>{username}</b> and temporary password is <b>{####}</b>
      <p>To log in, browse to <span style="color: #5100ff;">https://${local.domain_admin_portal}</span></p> <p>You will be prompted to change your password when you first log in, this password will expire in 1 day.</p>
      <br/><br/> <br/>
      <h4>Powered by Aventus (www.aventus.io)</h4>
    </div>
EOT
      email_subject = "${title(replace(var.name, "-", " "))} registration - your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}."
    }
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  password_policy {
    minimum_length                   = var.cognito.password_policy.minimum_length
    require_lowercase                = var.cognito.password_policy.require_lowercase
    require_numbers                  = var.cognito.password_policy.require_numbers
    require_symbols                  = var.cognito.password_policy.require_symbols
    require_uppercase                = var.cognito.password_policy.require_uppercase
    temporary_password_validity_days = var.cognito.password_policy.temporary_password_validity_days
  }

  software_token_mfa_configuration {
    enabled = var.cognito.software_token_mfa_configuration
  }

  user_pool_add_ons {
    advanced_security_mode = var.cognito.user_pool_add_ons
  }

  device_configuration {
    challenge_required_on_new_device      = var.cognito.device_configuration.challenge_required_on_new_device
    device_only_remembered_on_user_prompt = var.cognito.device_configuration.device_only_remembered_on_user_prompt
  }

  deletion_protection = var.cognito.deletion_protection
  mfa_configuration   = var.cognito.mfa_configuration
  username_attributes = var.cognito.username_attributes

  schema {
    attribute_data_type      = "String"
    name                     = "groups"
    developer_only_attribute = false
    mutable                  = true
    required                 = false

    string_attribute_constraints {}
  }

  tags = merge(var.cognito.tags, { Name = coalesce(var.cognito.override_name, var.name) })

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cognito_user_pool_domain" "admin_portal" {
  domain          = var.cognito.domain
  certificate_arn = var.cognito.certificate_arn
  user_pool_id    = aws_cognito_user_pool.admin_portal.id
}

resource "aws_cognito_user_pool_client" "admin_portal" {
  name                                 = coalesce(var.cognito.override_name, "${var.name}-admin-portal")
  user_pool_id                         = aws_cognito_user_pool.admin_portal.id
  generate_secret                      = var.cognito.pool_client.generate_secret
  allowed_oauth_flows_user_pool_client = var.cognito.pool_client.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = var.cognito.pool_client.allowed_oauth_flows
  explicit_auth_flows                  = var.cognito.pool_client.explicit_auth_flows
  allowed_oauth_scopes                 = var.cognito.pool_client.allowed_oauth_scopes
  callback_urls                        = var.cognito.pool_client.callback_urls
  logout_urls                          = var.cognito.pool_client.logout_urls
  prevent_user_existence_errors        = var.cognito.pool_client.prevent_user_existence_errors
  supported_identity_providers         = var.cognito.pool_client.supported_identity_providers

  # token_validity_units {
  #   access_token  = "minutes"
  #   id_token      = "minutes"
  #   refresh_token = "days"
  # }

  # included while https://github.com/hashicorp/terraform-provider-aws/issues/20298 is not addressed
  lifecycle {
    ignore_changes = [
      generate_secret,
      token_validity_units,
    ]
  }
}
resource "aws_cognito_user_group" "main" {
  name         = each.key
  user_pool_id = aws_cognito_user_pool.admin_portal.id
  description  = each.value

  for_each = { for k, v in concat(local.defaults_cognito_user_groups, var.cognito.extra_user_groups) : v.name => v.description }
}
