provider "aws" {
    region = "eu-central-1"
}

resource "aws_vpc" "my-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

module "my-subnet" {
    source = "./modules/subnet"
    subnet_cidr_block = var.subnet_cidr_block 
    avail_zone = var.avail_zone
    env_prefix = var.env_prefix
    vpc_id = aws_vpc.my-vpc.id
    default_route_table_id = aws_vpc.my-vpc.default_route_table_id
}

module "my-webserver" {
    source = "./modules/webserver"
     vpc_id = aws_vpc.my-vpc.id 
     my_ip = var.my_ip
     env_prefix = var.env_prefix
     image_name = var.image_name
     public_key_location = var.public_key_location
     instance_type = var.instance_type
     subnet_id = module.my-subnet.subnet.id
     avail_zone = var.avail_zone
}