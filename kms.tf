#
# KMS key to unseal gateway vault
#
resource "aws_kms_key" "gateway_vault" {
  description             = "${var.name} Vault unseal key"
  deletion_window_in_days = 10

  tags = {
    Name = "${var.name}-vault-kms"
  }
}

resource "aws_kms_alias" "gateway_vault" {
  name          = "alias/${var.name}/vault"
  target_key_id = aws_kms_key.gateway_vault.key_id
}
