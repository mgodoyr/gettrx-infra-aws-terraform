variable "vpc_cidr_block" {
  default = "10.0.0.0/20"
}

variable "availability_zones" {
  default = ["us-east-1a", "us-east-1b"]
}

# Define variables
variable "aws_access_key" {
  default = "put your key here -> example: AKLA2Y3YRCXNCIMT3ND0"
}
variable "aws_secret_key" {
  default = "put your secret here -> example: jv5VPcB3uONqWlOj58L6A3sOex6Ekw/zncMbZSls"
}
variable "aws_region" {
  default = "us-east-1"
}
variable "ec2_instance_type" {
  default = "t2.micro"
}