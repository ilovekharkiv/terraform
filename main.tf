provider "aws" {
    region = "eu-central-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "my_ip" {}
variable "instance_type" {}
variable "public_key_location" {}

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "my-subnet-1" {
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "my-gateway" {
    vpc_id = aws_vpc.my-vpc.id
    tags = {
        Name: "${var.env_prefix}-gateway"
    }
}

resource "aws_default_route_table" "main-route-table" {
     default_route_table_id = aws_vpc.my-vpc.default_route_table_id
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-gateway.id
    }
    tags = {
        Name: "${var.env_prefix}-main-route-table"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.my-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }
    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }
    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

resource "aws_key_pair" "dev-key-pair" {
    key_name = "terraform"
    public_key = file(var.public_key_location)
}

resource "aws_instance" "development" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.my-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone
    associate_public_ip_address = true
    key_name = aws_key_pair.dev-key-pair.key_name
   
    tags = {
        Name: "${var.env_prefix}-ec2"
    }
}

output "ec2_public_ips" {
    value = aws_instance.development.public_ip
}

output "ec2_public_dns" {
    value = aws_instance.development.public_dns
}