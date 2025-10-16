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

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name            = "main"
  cidr            = var.aws_vpc_cidr
  azs             = var.aws_vpc_azs
  private_subnets = var.aws_vpc_private_subnets
  public_subnets  = var.aws_vpc_public_subnets
  enable_dns_hostnames = var.aws_dns_hostnames
}



#create aws public subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.aws_vpc_public_subnets[0]
  availability_zone = var.aws_vpc_azs[0]

  tags = merge(local.common_tags, { Name = "public-subnet1" })
}

resource "aws_subnet" "public_subnet2" {
  vpc_id            = module.vpc.vpc_id
  cidr_block        = var.aws_vpc_public_subnets[1]
  availability_zone = var.aws_vpc_azs[1]

  tags = merge(local.common_tags, { Name = "public-subnet2" })
}

#create internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "main-igw" })
}

#create aws routing table
resource "aws_route_table" "web_rt" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "public-rt" })
}

#associate aws routing table with public subnet
resource "aws_route_table_association" "web_subnet1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.web_rt.id
}

# Security group#
# Nginx security group
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = module.vpc.vpc_id

  # HTTP access allow access from anywhere
  ingress {
    description = "HTTP from VPC"
    from_port   = var.aws_web_http_port
    to_port     = var.aws_web_http_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
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

#create virtual machine (3) or aws_instance
resource "aws_instance" "web_server" {
  count                       = var.aws_web_server_count
  ami                         = data.aws_ami.linux.id
  instance_type               = var.aws_instance_type
  subnet_id                   = module.vpc.private_subnets[2]
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = merge(local.common_tags, { Name = "web-server-${count.index + 1}" })

  user_data = templatefile("./templates/startupscript.tpl", {
    bucket = aws_s3_bucket.aws_storage.bucket
    key    = aws_s3_object.logo.key
  })

}
/*
#create virtual machine (4) or aws_instance
resource "aws_instance" "web_server2" {
  count                       = var.aws_web_server_count
  ami                         = data.aws_ami.linux.id
  instance_type               = var.aws_instance_type
  subnet_id                   = local.web_subnets[count.index]
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name

  tags = merge(local.common_tags, { Name = "web-server-${count.index + 1}" })

  user_data = templatefile("${path.module}/templates/startupscript.tpl", {
    bucket = aws_s3_bucket.aws_storage.bucket
    key    = aws_s3_object.logo.key
  })

}
*/



# aws_iam_role
resource "aws_iam_role" "ec2_role" {
  name = "ec2_role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}


# aws_iam_role_policy
resource "aws_iam_role_policy" "ec2_role_policy" {
  name = "ec2_role_policy"
  role = aws_iam_role.ec2_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:*"
      ],
      "Resource": "*"
    }
  ]
}

EOF
}

# aws_iam_instance_profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}


/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██

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
