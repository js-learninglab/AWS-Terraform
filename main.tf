provider "aws" {
    region = "us-west-2"
}

data "aws_ami" "windows" {
    most_recent = true

    filter {
        name = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
    }

    owners = ["801119661308"]
}

# create virtual network
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}

# create private subnet
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false  # Ensures no public IP is auto-assigned

  tags = {
    Name = "Terraform private-subnet"
  }
}

# create virtual machine or aws_instance
resource "aws_instance" "app_server" {
    ami = data.aws_ami.windows.id
    instance_type = var.instance_type
    subnet_id = aws_subnet.private.id
    associate_public_ip_address = false

    tags = {
        Name = var.instance_name
    }
}