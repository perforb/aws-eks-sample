module "iam_assumable_role_with_oidc" {
  source       = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version      = "~> 3.0"
  create_role  = true
  role_name    = "iam-test"
  provider_url = replace(module.eks.cluster_oidc_issuer_url, "https://", "")

  role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess",
  ]

  oidc_fully_qualified_subjects = [
    "system:serviceaccount:default:iam-test"
  ]
}

resource "kubernetes_service_account" "iam_test" {
  metadata {
    name      = "iam-test"
    namaspace = "default"
    annotations = {
      "eks.amazonaws.com/rolearn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/iamtest"
    }
  }
}

data "aws_caller_identity" "current" {}