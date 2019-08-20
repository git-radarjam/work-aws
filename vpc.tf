# Internet VPC
resource "aws_vpc" "production_vpc" {
  cidr_block           = "${var.vpc_ipv4_cidr}"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"

  tags = {
    Name = "Production VPC"
  }
}

# Private and Public Subnets
resource "aws_subnet" "public_subnet1" {
  vpc_id                  = "${aws_vpc.production_vpc.id}"
  cidr_block              = "${var.cidr_public_1}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.availability_zone_1}"

  tags = {
    Name = "Production: Public Subnet 1"
  }
}
resource "aws_subnet" "private_subnet1" {
  vpc_id                  = "${aws_vpc.production_vpc.id}"
  cidr_block              = "${var.cidr_private_1}"
  map_public_ip_on_launch = "true"
  availability_zone       = "${var.availability_zone_1}"

  tags = {
    Name = "Production: Private Subnet 1"
  }
}
resource "aws_subnet" "private_subnet2" {
  vpc_id                  = "${aws_vpc.production_vpc.id}"
  cidr_block              = "${var.cidr_private_2}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.availability_zone_2}"

  tags = {
    Name = "Production: Private Subnet 2"
  }
}
#Creates a gateway for VPC
resource "aws_internet_gateway" "production_gw" {
  vpc_id = "${aws_vpc.production_vpc.id}"
  tags = {
    Name = "Production: Gateway"
  }
}

#Creates a routing table for VPC
resource "aws_route_table" "production_rt" {
  vpc_id = "${aws_vpc.production_vpc.id}"

  route {
    cidr_block = "${var.cidr_all}"
    gateway_id = "${aws_internet_gateway.production_gw.id}"
  }

  tags = {
    Name = "Production: Routing Table"
  }
}

# Creates routing table association
resource "aws_route_table_association" "production_public_rt" {
  subnet_id      = "${aws_subnet.public_subnet1.id}"
  route_table_id = "${aws_route_table.production_rt.id}"
}

#Creates EC2/Standard security group with port ingress
resource "aws_security_group" "production_sg" {
  name        = "Production Security Group"
  description = "Allow incoming HTTP Connections & SSH Access"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_office}"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_office}"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["${var.cidr_office}"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.cidr_office}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["${var.cidr_all}"]
  }

  vpc_id = "${aws_vpc.production_vpc.id}"

  tags = {
    Name = "Production: Security Group"
  }
}

# Creates an Oracle Security Group
resource "aws_security_group" "allow_oracle" {
  vpc_id      = "${aws_vpc.production_vpc.id}"
  name        = "allow_oracle"
  description = "Allows Oracle"

  ingress {
    from_port       = 1521
    to_port         = 1521
    protocol        = "tcp"
    security_groups = ["${aws_security_group.production_sg.id}"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "Allow Oracle"
  }

}
