locals {
  # common config
  environment = "staging"
  region = "us-east-1"

  # vpc config
  az = ["us-east-1a", "us-east-1b"] 
  vpc_cidr = "10.10.0.0/16"
  priv_subnet_cidr = [ "10.10.5.0/24", "10.10.6.0/24" ]
  pub_subnet_cidr = [ "10.10.3.0/24", "10.10.4.0/24" ]
  priv_subnet = [ "priv-subnet-1", "priv-subnet-2" ]
  pub_subnet = [ "pub-subnet-1", "pub-subnet-2" ]

  # ec2 config
  instance_type = "t2.micro"
  key_name = "kene-devops-key"

  # rds config
  identifier = "postgres-db"
  db_engine = "postgres"
  db_eng_version = "16.6"
  instance_class = "db.t4g.micro"
  storage = 20
  db_username = "terraformstagingprojuser"
  db_name = "terraformstagingprojdb"
  subnet_grp_name = "subnet-group-db-stg"
}