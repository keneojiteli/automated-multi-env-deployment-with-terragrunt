# specifies which Terraform module to use and how to call it.
# goes to root folder and create both provider and backend for this resource (VPC)

include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "env" {
  path = find_in_parent_folders("env.hcl")
  expose = true
}

terraform {
  source = "../../../infrastructure-modules//vpc"
}

inputs = {
  environment      = include.env.locals.environment
  region           = include.env.locals.region
  az               = include.env.locals.az
  vpc_cidr         = include.env.locals.vpc_cidr
  priv_subnet_cidr = include.env.locals.priv_subnet_cidr
  pub_subnet_cidr  = include.env.locals.pub_subnet_cidr
  priv_subnet      = include.env.locals.priv_subnet
  pub_subnet       = include.env.locals.pub_subnet
}