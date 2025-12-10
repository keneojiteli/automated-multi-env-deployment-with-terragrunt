include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../infrastructure-modules//oidc-provider"
}

inputs = {
  oidc_provider  = "token.actions.githubusercontent.com"
}
