provider "aws" {
    region = "us-west-2"
}


provider "google"{
    project = "GCP-terraform-471706"
    region = "US-central1"
}

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

module "vpc2" {
  source = "terraform-google-modules/network/google"
  version ="12.0"

  project_id = "GCP-terraform-471706"
  network_name = "main"
  # ip_cidr_range = "11.0.0.0/16"

  subnets = [
    
  {
    subnet_name = "gcp_app_subnet"
    subnet_ip = "11.0.1.0/24"
    subnet_region = "us-west1"
  },
  {
    subnet_name = "gcp_db_subnet"
    subnet_ip = "11.0.2.0/24"
    subnet_region = "us-west1"
  }
  ]
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
    count = var.AWS_app_server_count
    ami = data.aws_ami.windows.id
    instance_type = var.AWS_instance_type
    subnet_id = module.vpc.private_subnets[0]
    associate_public_ip_address = false

    tags = {
        Name = var.AWS_APP_instance_name
    }
}

#create virtual machine(2) or aws_instance
resource "aws_instance" "db_server" {
  count = var.AWS_db_server_count
  ami = data.aws_ami.windows.id
  instance_type = var.AWS_instance_type
  subnet_id = module.vpc.private_subnets[1]
  associate_public_ip_address = false

  tags = {
        Name = var.AWS_DB_instance_name
  }
}

#create virtual machine (1) or google_compute_instance
resource "google_compute_instance" "gcp_app_server" {
  name  = var.GCP_app_instance_name
  count = var.GCP_app_server_count
  machine_type = var.GCP_instance_type
  
  network_interface{
  network = module.vpc2.main
  subnetwork = module.vpc2.gcp_app_subnet
    }
  tags = "var.GCP_APP_instance_name"
}

#create virtual machine (2) or google_compute_instance
resource "google_compute_instance" "gcp_db_server" {
  name  = var.GCP_db_instance_name
  count = var.GCP_db_server_count
  machine_type = var.GCP_instance_type

  network_interface {
  network = module.vpc2.main
  subnetwork = module.vpc2.gcp_db_subnet
  }
  tags = "var.GCP_DB_instance_name"
}