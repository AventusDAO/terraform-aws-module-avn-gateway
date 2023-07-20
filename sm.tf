#
# gateway rds
#
resource "aws_secretsmanager_secret" "rds" {
  name = replace("${lookup(var.rds, "override_name", var.name)}_rds_logins", "-", "_")
}

resource "aws_secretsmanager_secret_version" "rds" {
  secret_id     = aws_secretsmanager_secret.rds.id
  secret_string = jsonencode(local.rds_secrets)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#
# gateway amazonmq (rabbitmq)
#
resource "aws_secretsmanager_secret" "amazonmq" {
  name = replace("${lookup(var.amazon_mq, "override_name", var.name)}_amazonmq_logins", "-", "_")
}

resource "aws_secretsmanager_secret_version" "amazonmq" {
  secret_id     = aws_secretsmanager_secret.amazonmq.id
  secret_string = jsonencode(local.amazonmq_secrets)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#
# gateway cognito secret
#
resource "aws_secretsmanager_secret" "admin_portal" {
  name                    = replace("cognito_${var.name}_admin_details", "-", "_")
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_portal" {

  secret_id     = aws_secretsmanager_secret.connector.id
  secret_string = "{\"client_secret\":\"updated via AWS UI\"}"

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#
# gateway vault
#
resource "aws_secretsmanager_secret" "vault" {
  name = replace("${var.name}_vault", "-", "_")
}

resource "aws_secretsmanager_secret_version" "vault" {
  secret_id     = aws_secretsmanager_secret.vault.id
  secret_string = jsonencode(local.vault_secrets)

  lifecycle {
    ignore_changes = [secret_string]
  }
}

#
# gateway connector
#
resource "aws_secretsmanager_secret" "connector" {
  name = replace("${var.name}-connector", "-", "_")
}

resource "aws_secretsmanager_secret_version" "connector" {
  secret_id     = aws_secretsmanager_secret.connector.id
  secret_string = "{\"tier1_provider_url\":\"updated via AWS UI\"}"

  lifecycle {
    ignore_changes = [secret_string]
  }
}
