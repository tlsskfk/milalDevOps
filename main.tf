variable "region" {
    default = "us-east-1"
}

variable "availability_zone" {
    default = "us-east-1a"
}

provider "aws" {
    region = "${var.region}"
}

resource "aws_instance" "milal_cluster" {
    ami           = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
}

resource "aws_ebs_volume" "milal_mysql_volume" {
  availability_zone = "${var.availability_zone}"
  size              = 10
  type              = "gp2"
}