include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "../../../infrastructure-modules//db"
}

dependency "vpc" {
  config_path = "../vpc"
}

inputs = {
  environment    = include.env.locals.environment
  identifier     = include.env.locals.identifier
  db_engine      = include.env.locals.db_engine
  db_eng_version = include.env.locals.db_eng_version
  instance_class = include.env.locals.instance_class
  storage        = include.env.locals.storage
  db_username    = include.env.locals.db_username
  # db_password    = include.env.locals.db_password
  db_password    = getenv("DB_PASSWORD")
  db_name        = include.env.locals.db_name
  subnet_grp_name= include.env.locals.subnet_grp_name
  priv_subnet    = dependency.vpc.outputs.priv_subnet_id
  sg             = [dependency.vpc.outputs.vpc_sg] # format: dependency.<name>.outputs.<output_name>
}