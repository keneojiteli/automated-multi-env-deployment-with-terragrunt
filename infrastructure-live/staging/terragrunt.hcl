include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = "env.hcl"
  expose = true
}

locals {
  environment = include.env.locals.environment
  region      = include.env.locals.region
}

# Shared inputs available to all submodules
inputs = {
  environment = local.environment
  region      = local.region
}