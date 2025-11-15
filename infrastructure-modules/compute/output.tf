output "instance_pub_ip"{
    description = "public ip for ec2 instance"
    value = aws_instance.instance[*].public_ip
    # value = [for i in aws_instance.instance : i.public_ip]
}

