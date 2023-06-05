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
variable "rsa_key" {
    default ="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC8tCxMyYTeEEzuwpgzvHS2W09yiq6ka1cCXkMmPY6JI162u7UWeVRP6YOx53vkIsv8xFhMnf/kAQAhZ0rnKJgvQYR6leM1/5QZqoX06RBZIXCv+oWMSscVuqgg0plq/9W1YXMKA6H4fpT/4qg8B3k7vSBnebajWOGq6OfvBiNtBm0d08YT+1SQbWFi5qTSSa0E8kcmpFeKItDP8+jE0visZ8qgWd6StRX4JsWwi8nkDektaI7Kc/YcuNYnk4cJjyltyB0/qhxTBglAbXciDfyLjWcS6tByqzESiUEtAVTP8kv3j3ZT8QVyKP/zv9qJpLE/RevGmfM7bSuZpi4jiwQqLU0FBKLwkqezWxT7yOKLSFsBM2OHUKKx5uQpn966f9Ll8ERpg1OjxYbp3+q1P90GKtRB61j0xQ69QUWzoAOnsHAmPovbPl5WMTK5GgkBUMPe15BUpB7/5hNNG+G8wQ+HDGL8LShwwkfeZvNGIufffUehm+Qq6NagFQilyUdm4a8= shin@MacBook-Air-3"
}

resource "aws_key_pair" "ec2key" {
  key_name   = "ec2key"
  public_key = "${var.rsa_key}"
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

//public hosted zone / url
resource "aws_route53_zone" "milal-url" {
  name = "steveboy.click"
}

// subnets
resource "aws_subnet" "subnet-1-public" {
  cidr_block        = "${cidrsubnet(aws_vpc.milal-vpc.cidr_block, 3, 1)}"
  vpc_id            = "${aws_vpc.milal-vpc.id}"
  availability_zone = "us-east-1a"
}
resource "aws_route_table" "route-table-milal" {
  vpc_id = "${aws_vpc.milal-vpc.id}"
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.milal-internet-gw.id}"
  }
  tags = {
    Name = "route-table-milal"
  }
}
resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.subnet-1-public.id}"
  route_table_id = "${aws_route_table.route-table-milal.id}"
}

// security groups
resource "aws_security_group" "milal-ingress" {
name   = "allow-all-sg"
vpc_id = "${aws_vpc.milal-vpc.id}"
ingress {
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# rules needed for cluster managament in vpc
# normally this should be 6443:6443 but i am running docker at 6443
ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 10250
    to_port     = 10252
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
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