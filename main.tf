provider "aws" {
    region = "${var.region}"
}

variable "region" {
    default = "us-east-1"
}

variable "availability_zone" {
    default = "us-east-1a"
}

variable "ami_name" {
    default = "milal_cluster"
}

resource "aws_key_pair" "ec2key" {
  key_name   = "ec2key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC/t3++JjTjwXuKBoX6eGePtbPeezA7LholRvqZDmh38ojlpgjaE2vGCcYW2LTvYq0SCnEH8uf7rUstNMCKsONnyKVKjoeXbjl26+BLSZRz/qHU2bQXABS+KHivqdcANCdVmqWS/l9ggfu7mWEJIItdUMp7ZELH0JfAH7nDMIm1pfpGSIAOUSVixMg9fIbnZ7qniPJSlO/jxoi6/4uuscjobdJCnsrhXdR32WUh04u4c1DjQu96bVhHvPnwsrtsaZnpQoQymOh1Dz2p3Rqcv+8I4EU2r34eqjy4lk7aXPCpBLMffPnVRzwrcb9hV9ij9pxQs0FYN0SGTlID005SRe4QvzWNfK12RXAI5xU1EDfDMH6Fez4bGn1jmqjRuaoO++W6KMaop50w1/0q7TMU4T4ChLnSNhKWdPrIAJrcbJvd4HXWg7bpFtLPz0TLHPGTLookCCYLtaol7TGfp51AmD9t2Vl6dLHxMq3ztNKgRtYfPEowo/1Dt4td3Y1bAA7OjcU= shin@MacBook-Air-3"
}

// vpc
resource "aws_vpc" "milal-vpc" {
  cidr_block = "10.0.0.0/24"
  enable_dns_hostnames  = true
  enable_dns_support    = true
  tags                  = {
    Name = "milal-vpc"
  }
}
// public eip
resource "aws_eip" "milal-public-eip" {
  instance = "${aws_instance.milal_cluster.id}"
  vpc      = true
  depends_on = [aws_instance.milal_cluster]
}
//gateway
resource "aws_internet_gateway" "milal-internet-gw" {
  vpc_id  = "${aws_vpc.milal-vpc.id}"
  
  tags    = {
      Name = "milal-internet-gw"
    }
}

// subnets
resource "aws_subnet" "subnet-1-public" {
  cidr_block        = "${cidrsubnet(aws_vpc.milal-vpc.cidr_block, 3, 1)}"
  vpc_id            = "${aws_vpc.milal-vpc.id}"
  availability_zone = "us-east-1a"
}

// security group
resource "aws_security_group" "milal-ingress" {
name   = "allow-all-sg"
vpc_id = "${aws_vpc.milal-vpc.id}"
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
    from_port     = 22
    to_port   = 22
    protocol  = "tcp"
  }
// Terraform removes the default rule, normally aws gives us
  egress {
   from_port    = 0
   to_port      = 0
   protocol     = "-1"
   cidr_blocks  = ["0.0.0.0/0"]
 }
}

//k8s cluster ec2
resource "aws_instance" "milal_cluster" {
    ami                     = "ami-0557a15b87f6559cf"
    instance_type           = "t2.micro"
    key_name                = "${aws_key_pair.ec2key.key_name}"
    vpc_security_group_ids  = ["${aws_security_group.milal-ingress.id}"]
    subnet_id               = "${aws_subnet.subnet-1-public.id}"

    tags                    = {
        Name = "${var.ami_name}"
      }
    
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