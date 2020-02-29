terraform {
    required_version = ">= 0.12, < 0.13"
}

provider "aws" {
  region = "us-east-2"

  # Allow any 2.x version of the AWS provider
  version = "= 2.46"
}

resource "aws_instance" "example" {
  ami           = "ami-0d5d9d301c853a04a"
  instance_type = "t2.micro"

  tags = {
    Name = "2cloudlab-example"
  }
}