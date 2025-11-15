# tells terraform to expect remote state configuration
terraform {
  backend "s3" {}
}

# ec2
resource "aws_instance" "instance" {
    count = length(var.pub_subnet_id)
    ami = var.ami
    instance_type = var.instance_type
    subnet_id = var.pub_subnet_id[count.index] # child -child module dependency
    vpc_security_group_ids = var.sg_id # child -child module dependency, use argument ref bcos instance is created in a vpc 
    key_name = var.key_name
    tags = {
        Name = "${var.environment}-instance-${count.index}"
    }
}

