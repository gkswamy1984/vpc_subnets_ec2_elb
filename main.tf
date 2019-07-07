resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true

  tags = {
    Name = "esafe-vpc"
  }
}

# Define the public subnet
resource "aws_subnet" "public-subnet1" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet1_cidr}"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Web Public Subnet1"
  }
}

# Define the private subnet
resource "aws_subnet" "public-subnet2" {
  vpc_id = "${aws_vpc.default.id}"
  cidr_block = "${var.public_subnet2_cidr}"
  availability_zone = "us-east-1d"

  tags = {
    Name = "Web Public Subnet2"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.default.id}"

  tags = {
    Name = "VPC IGW"
  }
}

# Define the route table
resource "aws_route_table" "web-public-rt" {
  vpc_id = "${aws_vpc.default.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  tags = {
    Name = "Public Subnet RT"
  }
}

# Assign the route table to the public Subnet
resource "aws_route_table_association" "web-public1-rt" {
  subnet_id = "${aws_subnet.public-subnet1.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

resource "aws_route_table_association" "web-public2-rt" {
  subnet_id = "${aws_subnet.public-subnet2.id}"
  route_table_id = "${aws_route_table.web-public-rt.id}"
}

# Define the security group for public subnet
resource "aws_security_group" "sgweb" {
  name = "vpc_test_web"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  vpc_id="${aws_vpc.default.id}"

  tags = {
    Name = "Web Server SG"
  }
}

resource "aws_key_pair" "esafe-demo" {
  key_name = "esafe.demo"
  public_key = "${file("public_key")}"
}

resource "aws_instance" "web1" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.esafe-demo.key_name}"
  subnet_id                   = "${aws_subnet.public-subnet1.id}"
  private_ip                  = "${var.instance_ips1[0]}"
  user_data                   = "${file("script1.sh")}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.sgweb.id}",
  ]

  tags = {
    Name = "web-server1"
  }

}

resource "aws_instance" "web2" {
  ami                         = "${var.ami}"
  instance_type               = "${var.instance_type}"
  key_name                    = "${aws_key_pair.esafe-demo.key_name}"
  subnet_id                   = "${aws_subnet.public-subnet2.id}"
  private_ip                  = "${var.instance_ips2[0]}"
  user_data                   = "${file("script2.sh")}"
  associate_public_ip_address = true

  vpc_security_group_ids = [
    "${aws_security_group.sgweb.id}",
  ]

  tags = {
    Name = "web-server2"
  }

}

resource "aws_elb" "web" {
  name = "esafe-elb"

  subnets         = flatten(["${aws_subnet.public-subnet1.id}","${aws_subnet.public-subnet2.id}"])
  security_groups = ["${aws_security_group.sgweb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # The instances are registered automatically
  instances = flatten(["${aws_instance.web1.id}","${aws_instance.web2.id}"])
}

