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
  -  `amazon mq`
  -  `cognito`
  - `vault`
  - `connector`
- Multiple AWS `policies`.


**NOTE:** Bear in mind that after the first initialization two more actions are needed:
- duly fill the secret manager facilities
- Create user/passwords on the different database systems

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
| <a name="module_amazonmq"></a> [amazonmq](#module\_amazonmq) | cloudposse/mq-broker/aws | 3.1.0 |
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | terraform-aws-modules/apigateway-v2/aws | 2.2.2 |
| <a name="module_eks_iam_role_gateway_admin_portal"></a> [eks\_iam\_role\_gateway\_admin\_portal](#module\_eks\_iam\_role\_gateway\_admin\_portal) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_eks_iam_role_gateway_connector"></a> [eks\_iam\_role\_gateway\_connector](#module\_eks\_iam\_role\_gateway\_connector) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_eks_iam_role_gateway_vault"></a> [eks\_iam\_role\_gateway\_vault](#module\_eks\_iam\_role\_gateway\_vault) | cloudposse/eks-iam-role/aws | v2.1.0 |
| <a name="module_gateway_lambdas"></a> [gateway\_lambdas](#module\_gateway\_lambdas) | terraform-aws-modules/lambda/aws | 5.3.0 |
| <a name="module_gateway_sqs_queues_alarms"></a> [gateway\_sqs\_queues\_alarms](#module\_gateway\_sqs\_queues\_alarms) | terraform-aws-modules/cloudwatch/aws//modules/metric-alarm | 4.3.0 |
| <a name="module_lambdas_layers"></a> [lambdas\_layers](#module\_lambdas\_layers) | terraform-aws-modules/lambda/aws | 5.3.0 |
| <a name="module_memory_db"></a> [memory\_db](#module\_memory\_db) | terraform-aws-modules/memory-db/aws | v1.1.2 |
| <a name="module_rds"></a> [rds](#module\_rds) | terraform-aws-modules/rds/aws | 6.1.0 |
| <a name="module_sg_amazonmq"></a> [sg\_amazonmq](#module\_sg\_amazonmq) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sg_lambdas"></a> [sg\_lambdas](#module\_sg\_lambdas) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sg_memorydb"></a> [sg\_memorydb](#module\_sg\_memorydb) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sg_rds"></a> [sg\_rds](#module\_sg\_rds) | terraform-aws-modules/security-group/aws | 5.1.0 |
| <a name="module_sqs_queues"></a> [sqs\_queues](#module\_sqs\_queues) | terraform-aws-modules/sqs/aws | 4.0.2 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cognito_user_pool.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool) | resource |
| [aws_cognito_user_pool_client.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_client) | resource |
| [aws_cognito_user_pool_domain.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cognito_user_pool_domain) | resource |
| [aws_db_subnet_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_iam_policy.gateway_invalid_transaction_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_send_handler_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_split_fee_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.gateway_tx_dispatch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_kms_alias.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_route53_record.admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_secretsmanager_secret.amazonmq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.amazonmq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.cognito](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.gateway_admin_portal](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_connector](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_invalid_transaction_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_send_handler_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_split_fee_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_tx_dispatch_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.gateway_vault](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_secretsmanager_secret_version.gateway_amazonmq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_vpc.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_amazon_mq"></a> [amazon\_mq](#input\_amazon\_mq) | Subset of Amazon MQ cluster configurations used on 'cloudposse/mq-broker/aws' module. | <pre>object({<br>    override_name              = optional(string) #if not set, var.name is used<br>    apply_immediately          = optional(bool)<br>    auto_minor_version_upgrade = optional(bool)<br>    deployment_mode            = optional(string)<br>    engine_type                = optional(string)<br>    engine_version             = optional(string)<br>    host_instance_type         = optional(string)<br>    publicly_accessible        = optional(bool)<br>    general_log_enabled        = optional(bool)<br>    audit_log_enabled          = optional(bool)<br>    encryption_enabled         = optional(bool)<br>    subnet_ids                 = list(string)<br>  })</pre> | n/a | yes |
| <a name="input_api_gateway"></a> [api\_gateway](#input\_api\_gateway) | Subset of AWS API gateway configurations used on 'terraform-aws-modules/apigateway-v2/aws' module. | <pre>object({<br>    domain_name_suffix          = string<br>    domain_name_certificate_arn = string<br>    override_name               = optional(string) # if not set, var.name is used<br>    description                 = optional(string)<br>    protocol_type               = optional(string)<br>    cors_configuration = optional(<br>      object({<br>        allow_credentials = optional(bool)<br>        allow_headers     = optional(list(string))<br>        allow_methods     = optional(list(string))<br>        allow_origins     = optional(list(string))<br>        expose_headers    = optional(list(string))<br>        max_age           = optional(number)<br>      })<br>    )<br>    default_stage_access_log_format = optional(map(any)) # more here: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage#access_log_settings<br>    default_route_settings = optional(<br>      object({<br>        detailed_metrics_enabled = optional(bool)<br>        throttling_burst_limit   = optional(number)<br>        throttling_rate_limit    = optional(number)<br>      })<br>    )<br>    retention_in_days = optional(number)<br>    tags              = optional(map(any))<br>  })</pre> | n/a | yes |
| <a name="input_cognito"></a> [cognito](#input\_cognito) | n/a | <pre>object({<br>    domain                       = string<br>    certificate_arn              = string<br>    override_name                = optional(string) # if not set, var.name is used<br>    recovery_mechanism           = optional(list(string))<br>    allow_admin_create_user_only = optional(bool)<br>    password_policy = optional(<br>      object({<br>        minimum_length                   = optional(number)<br>        require_lowercase                = optional(bool)<br>        require_numbers                  = optional(bool)<br>        require_symbols                  = optional(bool)<br>        require_uppercase                = optional(bool)<br>        temporary_password_validity_days = optional(number)<br>    }))<br>    software_token_mfa_configuration = optional(bool)<br>    user_pool_add_ons                = optional(string)<br>    device_configuration = optional(<br>      object({<br>        challenge_required_on_new_device      = optional(bool)<br>        device_only_remembered_on_user_prompt = optional(bool)<br>      })<br>    )<br>    deletion_protection = optional(string)<br>    mfa_configuration   = optional(string)<br>    username_attributes = optional(list(string))<br>    pool_client = object({<br>      user_pool_id                         = optional(string)<br>      generate_secret                      = optional(bool)<br>      allowed_oauth_flows_user_pool_client = optional(bool)<br>      allowed_oauth_flows                  = optional(list(string))<br>      explicit_auth_flows                  = optional(list(string))<br>      allowed_oauth_scopes                 = optional(list(string))<br>      callback_urls                        = list(string)<br>      logout_urls                          = list(string)<br>      prevent_user_existence_errors        = optional(string)<br>      supported_identity_providers         = optional(list(string))<br>    })<br>    tags = optional(map(any))<br>  })</pre> | n/a | yes |
| <a name="input_eks_oidc_issuer_url"></a> [eks\_oidc\_issuer\_url](#input\_eks\_oidc\_issuer\_url) | OIDC provider from the EKS cluster where the connector, admin portal and Vault are running. | `string` | n/a | yes |
| <a name="input_lambda_version"></a> [lambda\_version](#input\_lambda\_version) | (Optional) Commit hash of deployed lambdas. By default 'latest' is used. | `string` | `"latest"` | no |
| <a name="input_lambdas"></a> [lambdas](#input\_lambdas) | Subset of AWS gateway lambdas and layers configurations used on 'terraform-aws-modules/lambda/aws' module. | <pre>object({<br>    vpc_subnet_ids            = list(string)<br>    layer_compatible_runtimes = optional(list(string))<br>    runtime                   = optional(string)<br>    zip_location = optional(<br>      object({<br>        bucket     = optional(string) # bucket where to fetch lambda zips<br>        key_prefix = optional(string) # bucket key prefix where to fetch lambda zips<br>      })<br>    )<br>    common_env_vars                   = optional(map(any))<br>    cloudwatch_logs_retention_in_days = optional(number)<br>    authorisation_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    send_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    poll_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    query_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    lift_processing_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    tx_status_update_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    vote_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    lower_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    split_fee_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    tx_dispatch_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>    invalid_transaction_handler = optional(<br>      object({<br>        env_vars    = optional(map(any))<br>        memory_size = optional(number)<br>        timeout     = optional(number)<br>      })<br>    )<br>  })</pre> | n/a | yes |
| <a name="input_memory_db"></a> [memory\_db](#input\_memory\_db) | Subset of AWS MemoryDB configurations used on 'terraform-aws-modules/memory-db/aws' module. | <pre>object({<br>    subnet_ids                 = list(string)<br>    sns_topic_arn              = string<br>    override_name              = optional(string) #if not set, var.name is used<br>    description                = optional(string)<br>    engine_version             = optional(string)<br>    auto_minor_version_upgrade = optional(bool)<br>    node_type                  = optional(string)<br>    num_shards                 = optional(number)<br>    num_replicas_per_shard     = optional(number)<br>    port                       = optional(number)<br>    tls_enabled                = optional(bool)<br>    maintenance_window         = optional(string)<br>    snapshot_retention_limit   = optional(number)<br>    snapshot_window            = optional(string)<br>    create_parameter_group     = optional(bool)<br>    parameter_group_name       = optional(string)<br>    subnet_group_name          = optional(string)<br>    subnet_group_description   = optional(string)<br>    subnet_group_tags          = optional(map(any))<br>    tags                       = optional(map(any))<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Full name used for all gateway AWS resources. The 'name' tag is also set. | `string` | n/a | yes |
| <a name="input_rds"></a> [rds](#input\_rds) | Subset of AWS RDS configurations used on 'terraform-aws-modules/rds/aws' module. | <pre>object({<br>    subnet_ids                            = list(string)<br>    override_name                         = optional(string) #if not set, var.name is used<br>    engine                                = optional(string)<br>    engine_version                        = optional(string)<br>    family                                = optional(string)<br>    major_engine_version                  = optional(string)<br>    instance_class                        = optional(string)<br>    auto_minor_version_upgrade            = optional(bool)<br>    storage_type                          = optional(string)<br>    allocated_storage                     = optional(number)<br>    max_allocated_storage                 = optional(number)<br>    username                              = optional(string)<br>    port                                  = optional(number)<br>    multi_az                              = optional(bool)<br>    maintenance_window                    = optional(string)<br>    backup_window                         = optional(string)<br>    enabled_cloudwatch_logs_exports       = optional(list(string))<br>    create_cloudwatch_log_group           = optional(bool)<br>    backup_retention_period               = optional(number)<br>    skip_final_snapshot                   = optional(bool)<br>    deletion_protection                   = optional(bool)<br>    performance_insights_enabled          = optional(bool)<br>    performance_insights_retention_period = optional(number)<br>    create_monitoring_role                = optional(bool)<br>    monitoring_interval                   = optional(number)<br>    monitoring_role_name                  = optional(string)<br>    parameters = optional(<br>      list(<br>        object(<br>          {<br>            name  = string<br>            value = number<br>          }<br>    )))<br>    tags = optional(map(any))<br>  })</pre> | n/a | yes |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | Zone id where to create gateway api record and admin portal record | `string` | n/a | yes |
| <a name="input_sqs"></a> [sqs](#input\_sqs) | List of FIFO queue names to create and its global configurations. Alarms for more than 20 messages on the DLQ will also be created. | <pre>object({<br>    queue_names                   = optional(list(string))<br>    fifo                          = optional(bool)<br>    message_retention_seconds     = optional(number)<br>    visibility_timeout_seconds    = optional(number)<br>    create_dlq                    = optional(bool)<br>    dlq_message_retention_seconds = optional(number)<br>    receive_wait_time_seconds     = optional(number)<br>    max_receive_count             = optional(number)<br>    alarms = object({<br>      alarm_description   = optional(string)<br>      comparison_operator = optional(string)<br>      evaluation_periods  = optional(number)<br>      threshold           = optional(number)<br>      period              = optional(number)<br>      unit                = optional(string)<br>      namespace           = optional(string)<br>      metric_name         = optional(string)<br>      statistic           = optional(string)<br>      dimensions = object({<br>        QueueName = string<br>      })<br>      alarm_actions = optional(string)<br>    })<br>  })</pre> | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where to host the Gateway resources. | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
