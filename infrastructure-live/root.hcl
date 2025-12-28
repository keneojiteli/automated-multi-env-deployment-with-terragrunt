# defines settings that all environments inherit as shown below

locals {
  region = "us-east-1"
  env = basename(get_terragrunt_dir())
}

# provider config
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite"
  contents  = <<EOF
provider "aws" {
  # region = "us-east-1"
  region = "${local.region}"
}
EOF
}

# remote state config
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-state-bucket-101325"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-state-lock-table"
  }

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}