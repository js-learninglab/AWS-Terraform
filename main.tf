provider "aws" {
    region = "us-west-2"
}

/*
provider "google"{
    project = "GCP-terraform"
    region = "US-central1"
}
*/
data "aws_ami" "windows" {
    most_recent = true

    filter {
        name = "name"
        values = ["Windows_Server-2022-English-Full-Base-*"]
    }

    owners = ["801119661308"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "main"
  cidr = "10.0.0.0/16"

  azs             = ["us-west-2a", "us-west-2b", "us-west-2c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  #public_subnets  = ["10.0.101.0/24"]

  enable_dns_hostnames    = true
}

# create virtual network
/*
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main-vpc"
  }
}
*/

# create private subnet
/*
resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = false  # Ensures no public IP is auto-assigned

  tags = {
    Name = "Terraform private-subnet"
  }
}
*/

# create virtual machine (1) or aws_instance
resource "aws_instance" "app_server" {
    count = var.app_server_count
    ami = data.aws_ami.windows.id
    instance_type = var.instance_type
    subnet_id = module.vpc.private_subnets[0]
    associate_public_ip_address = false

    tags = {
        Name = var.instance_name
    }
}

#create virtual machine(2) or aws_instance
resource "aws_instance" "db_server" {
  count = var.db_server_count
  ami = data.aws_ami.windows.id
  instance_type = var.instance_type
  subnet_id = module.vpc.private_subnets[1]
  associate_public_ip_address = false

  tags = {
        Name = var.instance_name
  }
}