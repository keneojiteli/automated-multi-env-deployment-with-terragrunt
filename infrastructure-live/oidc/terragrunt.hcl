include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../infrastructure-modules//iam-oidc"
}

inputs = {
  environment    = local.env
  github_repo    = "keneojiteli/automated-multi-env-deployment-with-terragrunt"
  oidc_provider  = "token.actions.githubusercontent.com"
}
