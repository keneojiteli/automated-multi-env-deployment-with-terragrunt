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
}

inputs = {
  environment   = include.env.locals.environment
  instance_type = include.env.locals.instance_type
  key_name      = include.env.locals.key_name
  pub_subnet_id = dependency.vpc.outputs.pub_subnet_id
  sg_id         = [dependency.vpc.outputs.vpc_sg] # format: dependency.<name>.outputs.<output_name>
}