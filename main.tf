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
#create aws vpc
resource "aws_vpc" "avpc" {
  cidr_block           = var.aws_vpc_cidr
   enable_dns_hostnames = true

  tags = {
    Name = "avpc"
  }
}

#create aws vpc subnet
resource "aws_subnet" "aweb_subnet" {
  vpc_id            = aws_vpc.avpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"

  tags = {
    Name = "aweb_subnet"
  }
}

#create internet gateway
resource "aws_internet_gateway" "aigw" {
  vpc_id = aws_vpc.avpc.id

  tags = {
    Name = "aigw"
  }
}

#create aws routing table


#associate aws routing table with public subnet


# Security group
resource "aws_security_group" "aweb_sg" {
  name        = "aweb_sg"
  description = "Allow HTTP  and HTTPS inbound traffic"
  
  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "HTTPS from anywhere"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
} 

#create virtual machine or aws_instance
resource "aws_instance" "aweb_server" {
  ami           = data.aws_ami.linux.id
  instance_type = var.aws_instance_type
  count         = var.aws_web_server_count

  #subnet_id                   = module.vpc1.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.aweb_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("./templates/startupscript.tpl", {
    web_server_name = "${var.aws_web_instance_name}-${count.index + 1}"
  })


  tags = {
    Name = "${var.aws_web_instance_name}-${count.index + 1}"
  }
}


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