variable "aws_region" {
  description = "Region for the VPC"
  default = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default = "192.168.0.0/24"
}

variable "public_subnet1_cidr" {
  description = "CIDR for the public subnet"
  default = "192.168.0.0/25"
}

variable "public_subnet2_cidr" {
  description = "CIDR for the private subnet"
  default = "192.168.0.128/25"
}

variable "ami" {
  description = "Amazon Linux AMI"
  default = "ami-0b898040803850657"
}

variable "instance_ips1" {
  description = "The IPs to use for our instances"
  default     = ["192.168.0.77"]
}

variable "instance_ips2" {
  description = "The IPs to use for our instances"
  default     = ["192.168.0.135"]
}

variable "instance_type" {
  description = "The instance type to launch."
  default     = "t2.micro"
}
