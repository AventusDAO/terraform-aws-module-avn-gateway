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

```

```

**NOTE:** Bear in mind that after the first initialization two more actions are needed:
- duly fill the secret manager facilities
- Create user/passwords on the different database systems
