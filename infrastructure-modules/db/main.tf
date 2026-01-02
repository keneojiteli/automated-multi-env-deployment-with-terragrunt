# tells terraform to expect remote state configuration
# terraform {
#   backend "s3" {}
# }

# provides an RDS DB subnet group resource (private subnet), a single resource that can take multiple subnets
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.environment}-subnnet-grp"
  subnet_ids = var.priv_subnet # child/child dependency, expects a list of subnet IDs

  tags = {
    Name = "${var.environment}-subnnet-grp"
    Environment = var.environment
    AllowDestroy = true
  }
}

# provides an RDS instance resource
resource "aws_db_instance" "my_db" {
  count = length(var.priv_subnet)
  identifier              = "${var.environment}-${var.identifier}-${count.index}"
  engine                  = var.db_engine
  engine_version          = var.db_eng_version
  instance_class          = var.instance_class
  allocated_storage       = var.storage
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = var.sg # child/child dependency
  username                = var.db_username
  password                = var.db_password
  db_name                 = var.db_name
  skip_final_snapshot     = true
  publicly_accessible     = false #keeps the RDS instance private

  tags = {
    Name = "${var.environment}-db"
    Environment = var.environment
    AllowDestroy = true
   }
}