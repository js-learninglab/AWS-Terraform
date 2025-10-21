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

data "aws_availability_zones" "available" {
  state = "available"
}

#create aws vpc
resource "aws_vpc" "a_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { name = "${local.prefix}-vpc" })

}

#create aws vpc subnet
resource "aws_subnet" "a_web_subnet1" {
  vpc_id            = aws_vpc.a_vpc.id
  cidr_block        = var.aws_vpc_a_web_subnets[0]
  //availability_zone = var.aws_us_west_regions[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  //map_public_ip_on_launch = true  #commented as i want to control public IP assignment on VPC level

  tags = merge(local.common_tags, { Name = "${local.prefix}a-web-subnet1" })
}

#create aws vpc subnet 2
resource "aws_subnet" "a_web_subnet2" {
  vpc_id            = aws_vpc.a_vpc.id
  cidr_block        = var.aws_vpc_a_web_subnets[1]
  //availability_zone = var.aws_us_west_regions[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  //map_public_ip_on_launch = true  #commented as i want to control public IP assignment on VPC level

  tags = merge(local.common_tags, { Name = "${local.prefix}-a-web-subnet2" })
}

#create internet gateway
resource "aws_internet_gateway" "a_igw" {
  vpc_id = aws_vpc.a_vpc.id

  tags = merge(local.common_tags, { Name = "${local.prefix}-igw" })
}

#create aws routing table
resource "aws_route_table" "a_rt" {
  vpc_id = aws_vpc.a_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a_igw.id
  }
  tags = merge(local.common_tags, { Name = "${local.prefix}-rt" })  
}

#associate aws routing table with public subnet
resource "aws_route_table_association" "a_rt_assoc_subnet1" {
  subnet_id      = aws_subnet.a_web_subnet1.id
  route_table_id = aws_route_table.a_rt.id
}

resource "aws_route_table_association" "a_rt_assoc_subnet2" {
  subnet_id      = aws_subnet.a_web_subnet2.id
  route_table_id = aws_route_table.a_rt.id
}

# Security group
resource "aws_security_group" "a_web_sg" {
  name        = "a_web_sg"
  description = "Allow HTTP  and HTTPS inbound traffic"
  vpc_id      = aws_vpc.a_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.aws_tcp_80
    to_port     = var.aws_tcp_80
    protocol    = var.aws_protocol_tcp
    cidr_blocks = [var.aws_vpc_cidr]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = var.aws_tcp_443
    to_port     = var.aws_tcp_443
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.prefix}-sg" })
}

resource "aws_security_group" "a_web_lb_sg" {
  name        = "a_web_lb_sg"
  description = "Allow HTTP  and HTTPS inbound traffic"
  vpc_id      = aws_vpc.a_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.aws_tcp_80
    to_port     = var.aws_tcp_80
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = var.aws_tcp_443
    to_port     = var.aws_tcp_443
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.prefix}-sg" })
}

#create virtual machine or aws_instance
resource "aws_instance" "a_web_server1" {
  ami           = data.aws_ami.linux.id
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.a_web_subnet1.id
  //count         = var.aws_web_server_count
  #subnet_id                  = module.vpc1.public_subnets[0]
  vpc_security_group_ids      = [aws_security_group.a_web_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("./templates/startupscript.tpl", {
    web_server_name = "${var.aws_web_instance_name}-a-web-server1"
  })

  tags = merge(local.common_tags, { Name = "${local.prefix}a-web-server1" })
}

resource "aws_instance" "a_web_server2" {
  ami           = data.aws_ami.linux.id
  instance_type = var.aws_instance_type
  subnet_id     = aws_subnet.a_web_subnet2.id
  //count         = var.aws_web_server_count
  #subnet_id                  = module.vpc1.public_subnets[1]
  vpc_security_group_ids      = [aws_security_group.a_web_sg.id]
  associate_public_ip_address = true
  user_data = templatefile("./templates/startupscript.tpl", {
    web_server_name = "${var.aws_web_instance_name}a-web-server2"
  })

  tags =  merge(local.common_tags, { Name = "${local.prefix}a-web-server2" })
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