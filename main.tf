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
    
    root_block_device {
        volume_size = 30
        volume_type = "gp2"
        tags        = {
            Name = "milal_cluster"
        }
  }
}

resource "aws_ebs_volume" "milal_mysql_volume" {
  availability_zone = "${var.availability_zone}"
  size              = 10
  type              = "gp2"
  tags              = {
    Name = "milal-mysql"
  }
}