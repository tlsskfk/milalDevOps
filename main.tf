variable "region" {
    default = "us-east-1"
}

provider "aws" {
    region = "${var.region}"
}

resource "aws_instance" "milal_cluster" {
    ami           = "ami-0557a15b87f6559cf"
    instance_type = "t2.micro"
}