provider "aws" {
    region = "us-east-1"
    access_key = "${TF_VAR_AWS_ACCESS_KEY}"
    secret_key = "${TF_VAR_AWS_SECRET_ACCESS_KEY}"
}

resource "aws_instance" "milal_master_node" {
  ami           = "ami-0557a15b87f6559cf"
  instance_type = "t2.micro"
}