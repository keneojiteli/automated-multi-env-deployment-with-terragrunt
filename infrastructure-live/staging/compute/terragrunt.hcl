include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "../../../infrastructure-modules//compute"
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {
    pub_subnet_id = "subnet-000000"
    vpc_sg        = "sg-000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs_merge_with_state           = true
}

inputs = {
  environment   = include.env.locals.environment
  instance_type = include.env.locals.instance_type
  key_name      = include.env.locals.key_name
  pub_subnet_id = dependency.vpc.outputs.pub_subnet_id
  sg_id         = [dependency.vpc.outputs.vpc_sg] # format: dependency.<name>.outputs.<output_name>
}