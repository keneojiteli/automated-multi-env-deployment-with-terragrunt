output "rds_instance_name" {
  value = aws_db_instance.my_db[*].id
}