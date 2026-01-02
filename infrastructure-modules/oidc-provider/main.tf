# tells terraform to expect remote state configuration
# terraform {
#   backend "s3" {}
# }

# OIDC PROVIDER (Created once per AWS account)
# Terragrunt will try to apply this in each env, but AWS sees it's identical and reuses it

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.oidc_provider}"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}