## Gateway terraform module

This module provisions all resources needed for the avn-gateway to work:
- AWS `amazon MQ` cluster (rabbitmq)
- AWS `MemoryDB` (redis)
- AWS `RDS`
- `SQS queues` and respective `alarms`
- Custom `DNS records` for the `api gateway` and `admin portal`
- Deployment of `lambda layers` and `lambdas`
- AWS `cognito pool` and `pool client` for `gateway admin portal`
- AWS `gateway api`
- `vault KMS key` used for auto-unseal
- Various AWS `Security groups`
- AWS roles for:
  - `lambdas`
  - `Vault service account`
  - `Admin portal service account`
  - `Connector service account`
- Secret Manager facilities pre-populated during the first apply:
  - `RDS`
  - `amazon mq`
  - `cognito`
  - `vault`
  - `connector`
- Multiple AWS `policies`.

Example use:
```
#
# TLS Certificate for cognito
#
module "gateway_cognito_acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "4.3.2"

  domain_name = "*.dev.aventus.network"
  zone_id     = data.aws_route53_zone.dev_zone.id

  wait_for_validation = true

  tags = {
    Name        = "Cognito gateway certificate"
    Description = "Managed via terraform"
    Project     = "Gateway"
  }

  providers = {
    aws = aws.us_east_1
  }
}

#
# avn gateway - all aws components
#
module "dev_gateway" {
  source = "git@github.com:Aventus-Network-Services/terraform-avn-gateway-module.git?ref=vx.x.x"

  name                = "dev-gateway"
  vpc_id              = <vpc id>
  route53_zone_id     = <zone id>
  eks_oidc_issuer_url = <oddc provider url>
  lambda_version      = <commit hash from gateway api repo>

  amazon_mq = {
    subnet_ids = ["id1", "id2" , ... ]
  }

  memory_db = {
    subnet_ids = ["id1", "id2" , ... ]
    sns_topic_arn = <sns topic arn>
  }

  rds = {
    subnet_ids = ["id1", "id2" , ... ]
  }

  sqs = {
    alarm = {
      alarm_actions =  <sns topic arn>
    }
  }

  lambdas = {
    vpc_subnet_ids = subnet_ids = ["id1", "id2" , ... ]

    tx_status_update_handler = {
      env_vars = {
        BLOCK_EXPLORER_BASE_URL = "..."
      }
    }
    vote_handler = {
      env_vars = {
        AVN_VOTES_BUCKET = "..."
      }
    }
  }

  api_gateway = {
    override_name               = "gateway"
    custom_domain          = "dev.aventus.network"
    domain_name_certificate_arn = <acm cert arn>
  }

  cognito = {
    domain          = "auth-gateway.dev.aventus.network"
    certificate_arn = module.gateway_cognito_acm.acm_certificate_arn

    pool_client = {
      callback_urls = ["<url1>"]
      logout_urls   = ["<url2>"]
    }
  }
}
```

**NOTE1:** Bear in mind that after the first initialization two more actions are needed:
- duly fill the secret manager facilities
- Create user/passwords on the different database systems

**NOTE2:** during the first apply, you should fill the amazonmq secret manager facility as soon as it's created.
Otherwise, a random app user/passw will be created and saved on terraform state.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.8 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | 5.0.0 |
| <a name="module_eks_iam_role_gateway_admin_portal"></a> [eks\_iam\_role\_gateway\_admin\_portal](#module\_eks\_iam\_role\_gateway\_admin\_portal) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_eks_iam_role_gateway_connector"></a> [eks\_iam\_role\_gateway\_connector](#module\_eks\_iam\_role\_gateway\_connector) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_eks_iam_role_gateway_vault"></a> [eks\_iam\_role\_gateway\_vault](#module\_eks\_iam\_role\_gateway\_vault) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_eventbridge"></a> [eventbridge](#module\_eventbridge) | terraform-aws-modules/eventbridge/aws | 3.2.3 |
| <a name="module_gateway_sqs_queues_alarms"></a> [gateway\_sqs\_queues\_alarms](#module\_gateway\_sqs\_queues\_alarms) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | 4.3.0 |
| <a name="module_lambdas"></a> [lambdas](#module\_lambdas) | terraform-aws-modules/lambda/aws | 7.2.2 |
| <a name="module_lambdas_layers"></a> [lambdas\_layers](#module\_lambdas\_layers) | terraform-aws-modules/lambda/aws | 7.2.2 |
| <a name="module_memory_db"></a> [memory\_db](#module\_memory\_db) | terraform-aws-modules/memory-db/aws | v1.1.2 |
| <a name="module_memory_db_monitoring"></a> [memory\_db\_monitoring](#module\_memory\_db\_monitoring) | git@github.com:Aventus-Network-Services/terraform-aws-memorydb-monitoring | v0.1.0 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 6.1.0 |
| <a name="module_rds_monitoring"></a> [rds\_monitoring](#module\_rds\_monitoring) | git@github.com:Aventus-Network-Services/terraform-aws-rds-monitoring | v0.1.0 |
| <a name="module_sg_lambdas"></a> [sg\_lambdas](#module\_sg\_lambdas) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sg_memorydb"></a> [sg\_memorydb](#module\_sg\_memorydb) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sg_rds"></a> [sg\_rds](#module\_sg\_rds) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sqs_queues"></a> [sqs\_queues](#module\_sqs\_queues) | terraform-aws-modules/sqs/aws | 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_apigatewayv2_api_mapping.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api_mapping) | resource |
| [aws_apigatewayv2_domain_name.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_domain_name) | resource |
| [aws_cloudwatch_event_target.lambdas](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cognito_user_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_group) | resource |
| [aws_cognito_user_pool.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.gateway_invalid_transaction_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_lift_processing_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_send_handler_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_split_fee_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_tx_dispatch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_vote_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_webhooks_event_emitter_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_webhooks_verification_key_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_kms_key.gateway_webhooks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_secretsmanager_secret.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.gateway_admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_invalid_transaction_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_invalid_transaction_access_merged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_lift_processing_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_send_handler_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_send_handler_access_merged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_split_fee_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_split_fee_access_merged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_tx_dispatch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_tx_dispatch_merged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_vote_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_webhooks_event_emitter_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_webhooks_verification_key_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_vpc.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_api_gateway"></a> [api\_gateway](#input\_api\_gateway) | Subset of AWS API gateway configurations used on 'terraform-aws-modules/apigateway-v2/aws' module. | <pre>object({<br>    domain_name                 = string<br>    domain_name_certificate_arn = string<br>    override_name               = optional(string) # if not set, var.name is used<br>    description                 = optional(string)<br>    protocol_type               = optional(string, "HTTP")<br>    cors_configuration = optional(<br>      object({<br>        allow_credentials = optional(bool)<br>        allow_headers     = optional(list(string))<br>        allow_methods     = optional(list(string))<br>        allow_origins     = optional(list(string))<br>        expose_headers    = optional(list(string))<br>        max_age           = optional(number)<br>        }<br>      ),<br>      {<br>        allow_credentials = false<br>        allow_headers     = ["*"]<br>        allow_methods     = ["*"]<br>        allow_origins     = ["*"]<br>        expose_headers    = ["*"]<br>        max_age           = 100<br>      }<br>    )<br>    default_stage_access_log_format = optional(string) # more here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage#access_log_settings<br>    stage_default_route_settings = optional(<br>      object({<br>        detailed_metrics_enabled = optional(bool)<br>        throttling_burst_limit   = optional(number)<br>        throttling_rate_limit    = optional(number)<br>        }<br>      ),<br>      {<br>        detailed_metrics_enabled = true<br>        throttling_burst_limit   = 100<br>        throttling_rate_limit    = 100<br>      }<br>    )<br>    retention_in_days = optional(number, 14)<br>    tags              = optional(map(any), {})<br>  })</pre> | n/a | yes |
| <a name="input_cognito"></a> [cognito](#input\_cognito) | Subset of AWS Cognito configurations used on 'terraform-aws-modules/apigateway-v2/aws' module. | <pre>object({<br>    domain                       = string<br>    certificate_arn              = string<br>    override_name                = optional(string) # if not set, var.name is used<br>    recovery_mechanism           = optional(list(string), ["verified_email"])<br>    allow_admin_create_user_only = optional(bool, true)<br>    password_policy = optional(<br>      object({<br>        minimum_length                   = optional(number)<br>        require_lowercase                = optional(bool)<br>        require_numbers                  = optional(bool)<br>        require_symbols                  = optional(bool)<br>        require_uppercase                = optional(bool)<br>        temporary_password_validity_days = optional(number)<br>        }<br>      ),<br>      {<br>        minimum_length                   = 12<br>        require_lowercase                = true<br>        require_numbers                  = true<br>        require_symbols                  = true<br>        require_uppercase                = true<br>        temporary_password_validity_days = 1<br>      }<br>    )<br>    software_token_mfa_configuration = optional(bool, true)<br>    user_pool_add_ons                = optional(string, "OFF")<br>    device_configuration = optional(<br>      object({<br>        challenge_required_on_new_device      = optional(bool)<br>        device_only_remembered_on_user_prompt = optional(bool)<br>        }<br>      ),<br>      {<br>        challenge_required_on_new_device      = true<br>        device_only_remembered_on_user_prompt = true<br>      }<br>    )<br>    deletion_protection = optional(string, "ACTIVE")<br>    mfa_configuration   = optional(string, "OPTIONAL")<br>    username_attributes = optional(list(string), ["email"])<br>    pool_client = object({<br>      callback_urls                        = list(string)<br>      logout_urls                          = list(string)<br>      generate_secret                      = optional(bool, true)<br>      allowed_oauth_flows_user_pool_client = optional(bool, true)<br>      allowed_oauth_flows                  = optional(list(string), ["code"])<br>      explicit_auth_flows = optional(<br>        list(string),<br>        [<br>          "ALLOW_CUSTOM_AUTH",<br>          "ALLOW_REFRESH_TOKEN_AUTH",<br>          "ALLOW_USER_PASSWORD_AUTH",<br>          "ALLOW_USER_SRP_AUTH"<br>        ]<br>      )<br>      allowed_oauth_scopes          = optional(list(string), ["email", "openid"])<br>      prevent_user_existence_errors = optional(string, "ENABLED")<br>      supported_identity_providers  = optional(list(string), ["COGNITO"])<br>    })<br>    extra_user_groups = optional(list(object({<br>      name        = string<br>      description = optional(string)<br>    })), [])<br>    tags = optional(map(any), {})<br>  })</pre> | n/a | yes |
| <a name="input_eks_oidc_issuer_url"></a> [eks\_oidc\_issuer\_url](#input\_eks\_oidc\_issuer\_url) | OIDC provider from the EKS cluster where the connector, admin portal and Vault are running. | `string` | n/a | yes |
| <a name="input_lambda_version"></a> [lambda\_version](#input\_lambda\_version) | (Optional) Commit hash of deployed lambdas. By default 'latest' is used. | `string` | `"latest"` | no |
| <a name="input_lambdas"></a> [lambdas](#input\_lambdas) | Subset of AWS gateway lambdas and layers configurations used on 'terraform-aws-modules/lambda/aws' module. | <pre>object({<br>    vpc_subnet_ids            = list(string)<br>    extra_envs                = optional(bool, true)<br>    layer_compatible_runtimes = optional(list(string), ["nodejs14.x"])<br>    runtime                   = optional(string, "nodejs14.x")<br>    zip_location = optional(<br>      object({<br>        bucket     = optional(string)<br>        key_prefix = optional(string)<br>        }<br>      ),<br>      {<br>        bucket     = "aventus-internal-artefact"<br>        key_prefix = "gateway-lambdas"<br>      }<br>    )<br>    common_env_vars                   = optional(map(any), {})<br>    cloudwatch_logs_retention_in_days = optional(number, 14)<br>    authorisation_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = { MAX_TOKEN_AGE_MSEC = 600000, MIN_AVT_BALANCE = "1000000000000000000" }<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br>    send_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br>    poll_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 256<br>        timeout     = 30<br>      }<br>    )<br>    query_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 256<br>        timeout     = 30<br>      }<br>    )<br>    lift_processing_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 256<br>        timeout     = 30<br>      }<br>    )<br>    tx_status_update_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 256<br>        timeout     = 30<br>      }<br>    )<br>    vote_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any), {})<br>        memory_size                   = optional(number, 256)<br>        timeout                       = optional(number, 30)<br>        override_event_source_mapping = optional(map(any), null)<br>        vote_bucket                   = string<br>        }<br>      )<br>    )<br>    lower_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 256<br>        timeout     = 30<br>      }<br>    )<br>    split_fee_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br>    tx_dispatch_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br>    invalid_transaction_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br><br>    webhooks_event_emitter_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br><br>    webhooks_verification_key_handler = optional(<br>      object({<br>        env_vars                      = optional(map(any))<br>        extra_policy_document         = optional(string)<br>        memory_size                   = optional(number)<br>        timeout                       = optional(number)<br>        override_event_source_mapping = optional(map(any), null)<br>        }<br>      ),<br>      {<br>        env_vars    = {}<br>        memory_size = 512<br>        timeout     = 30<br>      }<br>    )<br>  })</pre> | n/a | yes |
| <a name="input_memory_db"></a> [memory\_db](#input\_memory\_db) | Subset of AWS MemoryDB configurations used on 'terraform-aws-modules/memory-db/aws' module. | <pre>object({<br>    subnet_ids                 = list(string)<br>    create                     = optional(bool, true)<br>    override_name              = optional(string) #if not set, var.name is used<br>    description                = optional(string, "Gateway MemoryDB cluster (redis)")<br>    engine_version             = optional(string, "6.2")<br>    auto_minor_version_upgrade = optional(bool, false)<br>    node_type                  = optional(string, "db.t4g.small")<br>    num_shards                 = optional(number, 1)<br>    num_replicas_per_shard     = optional(number, 2)<br>    kms_key_arn                = optional(string, null)<br>    port                       = optional(number, 6379)<br>    tls_enabled                = optional(bool, false)<br>    maintenance_window         = optional(string, "tue:09:00-tue:10:00")<br>    snapshot_name              = optional(string)<br>    snapshot_retention_limit   = optional(number, 14)<br>    snapshot_window            = optional(string, "06:00-07:00")<br>    create_parameter_group     = optional(bool, false)<br>    parameter_group_name       = optional(string, "default.memorydb-redis6")<br>    subnet_group_name          = optional(string)<br>    subnet_group_description   = optional(string)<br>    subnet_group_tags          = optional(map(any), {})<br>    tags                       = optional(map(any), {})<br>  })</pre> | n/a | yes |
| <a name="input_monitoring_sns_topic_arn"></a> [monitoring\_sns\_topic\_arn](#input\_monitoring\_sns\_topic\_arn) | SNS topic ARN where to send alarms. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Full name used for all gateway AWS resources. The 'name' tag is also set. | `string` | n/a | yes |
| <a name="input_rds"></a> [rds](#input\_rds) | Subset of AWS RDS configurations used on 'terraform-aws-modules/rds/aws' module. | <pre>object({<br>    subnet_ids                            = list(string)<br>    create                                = optional(bool, true)<br>    override_name                         = optional(string) #if not set, var.name is used<br>    engine                                = optional(string, "postgres")<br>    engine_version                        = optional(string, "14.10")<br>    family                                = optional(string, "postgres14")<br>    major_engine_version                  = optional(string, "14")<br>    instance_class                        = optional(string, "db.t4g.small")<br>    auto_minor_version_upgrade            = optional(bool, false)<br>    storage_type                          = optional(string, "gp3")<br>    allocated_storage                     = optional(number, 20)<br>    max_allocated_storage                 = optional(number, 50)<br>    username                              = optional(string, "root")<br>    port                                  = optional(number, 5432)<br>    snapshot_identifier                   = optional(string)<br>    ca_cert_identifier                    = optional(string, "rds-ca-ecc384-g1")<br>    kms_key_id                            = optional(string, null)<br>    multi_az                              = optional(bool, false)<br>    maintenance_window                    = optional(string, "Tue:10:00-Tue:11:00")<br>    backup_window                         = optional(string, "07:00-08:00")<br>    enabled_cloudwatch_logs_exports       = optional(list(string), ["postgresql", "upgrade"])<br>    create_cloudwatch_log_group           = optional(bool, true)<br>    backup_retention_period               = optional(number, 7)<br>    skip_final_snapshot                   = optional(bool, false)<br>    deletion_protection                   = optional(bool, true)<br>    performance_insights_enabled          = optional(bool, true)<br>    performance_insights_retention_period = optional(number, 7)<br>    create_monitoring_role                = optional(bool, true)<br>    monitoring_interval                   = optional(number, 60)<br>    monitoring_role_name                  = optional(string)<br>    allowed_cidr_blocks                   = optional(list(string), [])<br>    parameters = optional(<br>      list(<br>        object(<br>          {<br>            name  = string<br>            value = any<br>          }<br>      )),<br>      [<br>        {<br>          name  = "autovacuum"<br>          value = 1<br>        },<br>        {<br>          name  = "client_encoding"<br>          value = "utf8"<br>        },<br>        {<br>          name  = "rds.force_ssl"<br>          value = 0<br>        },<br>        {<br>          name  = "ssl"<br>          value = 0<br>        }<br>      ]<br>    )<br>    tags = optional(map(any), {})<br>  })</pre> | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Zone id where to create cognito admin portal custom domain record. | `string` | n/a | yes |
| <a name="input_secret_manager_settings"></a> [secret\_manager\_settings](#input\_secret\_manager\_settings) | AWS Secret Manager config for AvN Gateway | <pre>object({<br>    prefix                  = optional(string, "gateway")<br>    recovery_window_in_days = optional(number, 30)<br>    kms_key_id              = optional(string, null)<br>    tags                    = optional(map(any), {})<br>  })</pre> | <pre>{<br>  "kms_key_id": null,<br>  "prefix": "gateway",<br>  "recovery_window_in_days": 30,<br>  "tags": {}<br>}</pre> | no |
| <a name="input_sqs"></a> [sqs](#input\_sqs) | List of FIFO queue names to create and its global configurations. Alarms for more than 20 messages on the DLQ will also be created. | <pre>object({<br>    default_queue_name            = string<br>    payer_queue_name              = string<br>    tx_queue_name                 = string<br>    webhooks_queue_name           = string<br>    fifo                          = optional(bool, true)<br>    message_retention_seconds     = optional(number, 86400)<br>    visibility_timeout_seconds    = optional(number, 60)<br>    create_dlq                    = optional(bool, true)<br>    dlq_message_retention_seconds = optional(number, 1209600)<br>    receive_wait_time_seconds     = optional(number, 10)<br>    max_receive_count             = optional(number, 3)<br>    delay_seconds                 = optional(number, 1)<br>    dlq_delay_seconds             = optional(number, 0)<br>    kms_master_key_id             = optional(string, null)<br>    dlq_kms_master_key_id         = optional(string, null)<br>    alarm = object({<br>      alarm_description   = optional(string)<br>      comparison_operator = optional(string, "GreaterThanOrEqualToThreshold")<br>      evaluation_periods  = optional(number, 1)<br>      threshold           = optional(number, 20)<br>      period              = optional(number, 300)<br>      unit                = optional(string, "Count")<br>      namespace           = optional(string, "AWS/SQS")<br>      metric_name         = optional(string, "NumberOfMessagesSent")<br>      statistic           = optional(string, "Sum")<br>      alarm_actions       = string<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where to host the Gateway resources. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rds"></a> [rds](#output\_rds) | RDS outputs |
<!-- END_TF_DOCS -->
