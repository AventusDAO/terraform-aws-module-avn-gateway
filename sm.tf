
resource "aws_secretsmanager_secret" "this" {
  name                    = "${var.secret_manager_settings.prefix}/${each.key}"
  recovery_window_in_days = var.secret_manager_settings.recovery_window_in_days
  kms_key_id              = var.secret_manager_settings.kms_key_id
  tags                    = var.secret_manager_settings.tags

  for_each = {
    for k, v in local.sm : k => v
  }
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id     = aws_secretsmanager_secret.this[each.key].id
  secret_string = jsonencode(each.value.value)

  lifecycle {
    ignore_changes = [secret_string]
  }

  for_each = {
    for k, v in local.sm : k => v
  }
}
