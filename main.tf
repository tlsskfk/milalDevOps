provider "aws" {
    region = "us-east-1"
    access_key = process.env.AWS_
}

resource "aws_ami" "milal_master_node" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
}