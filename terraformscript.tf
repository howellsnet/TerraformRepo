#EC2
provider "aws" {
  region     = "us-east-1"
}

#VPC
resource "aws_vpc" "dev" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "Dev_VPC"
  }
}

#Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "dev_private_subnet"
  }
}

#Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.dev.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "dev_public_subnet"
  }
}

#Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.dev.id

  tags = {
    Name = "Dev_GW"
  }
}

#Route Tables
resource "aws_route_table" "route" {
  vpc_id = aws_vpc.dev.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gateway.id
  }

  tags = {
    Name = "devVPCroute"
  }
}

#Association of Subnets & RouteTables
resource "aws_route_table_association" "association1" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.route.id
}
resource "aws_route_table_association" "association2" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.route.id
}

#VPC Security Group
resource "aws_security_group" "devSecGroup" {
  name        = "devSecGroup"
  description = "Allow TLS inbound traffic for port 22"
  vpc_id      = aws_vpc.dev.id

  ingress {
    description = "TLS from VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevSecGroup"
  }
}

#/***** AMI & KeyPair ****/
/*
resource "aws_instance" "web" {
  ami           = "ami-096fda3c22c1c990a"
  instance_type = "t2.micro"
  key_name   = "howells_perm"
  subnet_id = "${aws_subnet.public.id}"
  security_groups = [aws_security_group.devSecGroup.id]

  tags = {
    Name = "Webinstance"
  }
}
*/
