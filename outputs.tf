output "ec2_public_ips" {
    value = aws_instance.development.public_ip
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}