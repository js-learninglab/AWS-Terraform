/*
 ██████  ██████   ██████  ██    ██ ██ ██████  ███████ ██████  
 ██   ██ ██   ██ ██    ██ ██    ██ ██ ██   ██ ██      ██   ██ 
 ██████  ██████  ██    ██ ██    ██ ██ ██   ██ █████   ██████  
 ██      ██   ██ ██    ██  ██  ██  ██ ██   ██ ██      ██   ██ 
 ██      ██   ██  ██████    ████   ██ ██████  ███████ ██   ██ 
*/

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

/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/

data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  owners = ["801119661308"]
}

data "aws_ami" "linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  owners = ["137112412989"]
}




#create aws public subnet


#create internet gateway


#create aws routing table


#associate aws routing table with public subnet


# Security group#



#create virtual machine or aws_instance



/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██

module "gcp_vpc" {
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

*/