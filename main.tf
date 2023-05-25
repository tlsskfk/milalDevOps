provider "aws" {
    region = "${var.region}"
}

variable "region" {
    default = "us-east-1"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "" {
    default = ""
}

// vpc
resource "aws_vpc" "milal-vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags {
    Name = "milal-vpc"
  }
}

//k8s cluster ec2
resource "aws_instance" "milal_cluster" {
    ami           = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
    
    root_block_device {
        volume_size = 30
        volume_type = "gp2"
        tags        = {
            Name = "milal_cluster"
        }
  }
}

//k8s mysql container volume
resource "aws_ebs_volume" "milal_mysql_volume" {
  availability_zone = "${var.availability_zone}"
  size              = 10
  type              = "gp2"
  tags              = {
    Name = "milal-mysql"
  }
}