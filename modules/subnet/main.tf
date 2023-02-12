resource "aws_subnet" "my-subnet-1" {
    vpc_id = var.vpc_id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_internet_gateway" "my-gateway" {
    vpc_id = var.vpc_id
    tags = {
        Name: "${var.env_prefix}-gateway"
    }
}

resource "aws_default_route_table" "main-route-table" {
     default_route_table_id = var.default_route_table_id
     route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.my-gateway.id
    }
    tags = {
        Name: "${var.env_prefix}-main-route-table"
    }
}