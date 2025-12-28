include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../infrastructure-modules//state-lock"
}

# Skip remote state for this module to avoid circular dependency
skip_remote_state = true

# Use local backend for state locking table
terraform_backend {
  backend = "local"
  config = {
    path = "terraform.tfstate"
  }
}

inputs = {
  table_name  = "terraform-state-lock-table"
  environment = "shared"
  region      = "us-east-1"
  tags = {
    Purpose = "Terraform State Locking"
    Project = "Multi-Environment IaC"
  }
}