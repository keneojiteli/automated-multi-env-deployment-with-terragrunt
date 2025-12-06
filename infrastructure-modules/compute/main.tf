# tells terraform to expect remote state configuration
terraform {
  backend "s3" {}
}


# get existing AMI from my AWS account
# ensure the AMI's architecture is compatible with choosen instance type
# use filters found on the choosen AMI for easy find/use
data "aws_ami" "main" {
  most_recent = true
  owners      = ["602401143452"]

  filter {
    name   = "name"
    values = ["amazon-eks-node-al2023-x86_64-standard-1.24-v20240625"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ec2
resource "aws_instance" "instance" {
    count = length(var.pub_subnet_id)
    ami = data.aws_ami.main.id
    instance_type = var.instance_type
    subnet_id = var.pub_subnet_id[count.index] # child -child module dependency
    vpc_security_group_ids = var.sg_id # child -child module dependency, use argument ref bcos instance is created in a vpc 
    key_name = var.key_name
    tags = {
        Name = "${var.environment}-instance-${count.index}"
        Environment = var.environment
        AllowDestroy = true
    }
}

