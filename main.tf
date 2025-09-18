provider "aws" {
  #access_key = var.aws_access_key
  #secret_key = var.aws_secret_key
  region = var.aws_region
}


provider "google" {
  #credentials = var.gcp_credentials
  project = "GCP-terraform-471706"
  region  = var.gcp_region
}

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  owners = ["801119661308"]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name            = "main"
  cidr            = var.aws_vpc_cidr
  azs             = var.aws_vpc_azs
  private_subnets = var.aws_vpc_private_subnets
  #public_subnets  = ["10.0.101.0/24"]
  enable_dns_hostnames = var.aws_dns_hostnames
}

module "vpc2" {
  source  = "terraform-google-modules/network/google"
  version = "12.0"

  project_id   = "GCP-terraform-471706"
  network_name = "main"
  # ip_cidr_range = "11.0.0.0/16"


  subnets = [

    {
      subnet_name   = "gcp-app-subnet"
      subnet_ip     = var.gcp_vpc_subnets[0]
      subnet_region = var.gcp_vpc_region
    },
    {
      subnet_name   = "gcp-db-subnet"
      subnet_ip     = var.gcp_vpc_subnets[1]
      subnet_region = var.gcp_vpc_region
    }
  ]
}

# create virtual machine (1) or aws_instance
resource "aws_instance" "app_server" {
  count                       = var.aws_app_server_count
  ami                         = data.aws_ami.windows.id
  instance_type               = var.aws_instance_type
  subnet_id                   = module.vpc.private_subnets[0]
  associate_public_ip_address = false

  tags = merge(local.common_tags, { Name = "app-server-${count.index + 1}" })
}

#create virtual machine(2) or aws_instance
resource "aws_instance" "db_server" {
  count                       = var.aws_db_server_count
  ami                         = data.aws_ami.windows.id
  instance_type               = var.aws_instance_type
  subnet_id                   = module.vpc.private_subnets[1]
  associate_public_ip_address = false

  tags = merge(local.common_tags, { Name = "db-server-${count.index + 1}" })
}

#create virtual machine (1) or google_compute_instance
resource "google_compute_instance" "gcp_app_server" {
  name         = var.gcp_app_instance_name
  count        = var.gcp_app_server_count
  machine_type = var.gcp_instance_type
  zone         = var.gcp_vpc_region

  network_interface {
    network    = module.vpc2.network_id
    subnetwork = module.vpc2.subnets["us-west1/gcp-app-subnet"].id
  }

  boot_disk {
    initialize_params {
      image = "${var.gcp_image_project}/${var.gcp_image_family}"

      size = var.gcp_boot_disk_size
    }
  }
  tags = [var.gcp_app_instance_name]
}

#create virtual machine (2) or google_compute_instance
resource "google_compute_instance" "gcp_db_server" {
  name         = var.gcp_db_instance_name
  count        = var.gcp_db_server_count
  machine_type = var.gcp_instance_type
  zone         = var.gcp_vpc_region

  network_interface {
    network    = module.vpc2.network_id
    subnetwork = module.vpc2.subnets["us-west1/gcp-db-subnet"].id
  }

  boot_disk {
    initialize_params {
      image = "${var.gcp_image_project}/${var.gcp_image_family}"

      size = var.gcp_boot_disk_size
    }
  }
  tags = [var.gcp_db_instance_name]
}