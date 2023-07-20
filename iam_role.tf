# gateway_admin_portal
module "eks_iam_role_gateway_admin_portal" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "v2.1.0"

  aws_account_number          = data.aws_caller_identity.current.account_id
  eks_cluster_oidc_issuer_url = var.eks_oidc_issuer_url

  service_account_name      = "${var.name}-admin"
  service_account_namespace = "gateway"

  aws_iam_policy_document = [
    data.aws_iam_policy_document.gateway_admin_portal.json
  ]

  tags = {
    Name = "${var.name}-admin"
  }
}

#
# gateway vault
#
module "eks_iam_role_gateway_vault" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "v2.1.0"

  aws_account_number          = data.aws_caller_identity.current.account_id
  eks_cluster_oidc_issuer_url = var.eks_oidc_issuer_url

  service_account_name      = "${var.name}-vault"
  service_account_namespace = "gateway"

  aws_iam_policy_document = [
    data.aws_iam_policy_document.gateway_vault.json
  ]

  tags = {
    Name = "${var.name}-vault"
  }
}

#
# gateway connector
#
module "eks_iam_role_gateway_connector" {
  source  = "cloudposse/eks-iam-role/aws"
  version = "v2.1.0"

  aws_account_number          = data.aws_caller_identity.current.account_id
  eks_cluster_oidc_issuer_url = var.eks_oidc_issuer_url

  service_account_name      = "${var.name}-connector"
  service_account_namespace = "gateway"

  aws_iam_policy_document = [
    data.aws_iam_policy_document.gateway_connector.json
  ]

  tags = {
    Name = "${var.name}-connector"
  }
}
