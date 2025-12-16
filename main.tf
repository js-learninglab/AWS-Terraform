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
    name = "name"
    #values = ["amzn2-ami-hvm-*-x86_64-gp2"] Changing this because of its lower version of python
    values = ["al2023-ami-*-x86_64"]
  }

  owners = ["137112412989"]
}

data "aws_availability_zones" "available" {
  state = "available"
}

#create aws vpc using module
module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.5.0"

  cidr = var.aws_vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, var.aws_web_subnet_count)
  public_subnets = [for subnet in range(var.aws_web_subnet_count) : cidrsubnet(var.aws_vpc_cidr, 8, subnet)]

  enable_nat_gateway   = false #very expensive!
  enable_vpn_gateway   = false #not needed for this lab
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { name = "${local.naming_prefix}-${var.environment}-vpc" })
}
#removing below aws vpc creation as i am using vpc module now

# create aws s3 bucket using module
module "aws_s3" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.8.0"

  bucket = local.s3_bucket_name

  force_destroy = true

  tags = merge(local.common_tags, { Name = lower("${local.naming_prefix}-${var.environment}-s3-bucket") })
}

#create key pair to deploy
resource "aws_key_pair" "a_ec2_ssh_key" {
  key_name   = "a_ec2_ssh_key-${var.environment}"
  public_key = var.ec2_ssh_public_key

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ec2-ssh-key" })
}
#commenting vpc creation to use vpc module instead
/*
resource "aws_vpc" "a_vpc" {
  cidr_block           = var.aws_vpc_cidr
  enable_dns_hostnames = var.aws_vpc_enable_dns_hostnames

  tags = merge(local.common_tags, { name = "${local.naming_prefix}-vpc" })

}
*/

#commenting below resources as well to use vpc module instead
/*
#create aws vpc subnet
resource "aws_subnet" "a_web_subnets" {
  count = var.aws_web_subnet_count
  vpc_id     = aws_vpc.a_vpc.id
  cidr_block = var.aws_vpc_web_subnets_cidrs[count.index]
  //availability_zone = var.aws_us_west_regions[0]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  //map_public_ip_on_launch = true  #commented as i want to control public IP assignment on VPC level

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-a-web-subnets${count.index + 1}" })
}

#create aws vpc subnet 2 >>REMOVED BECAUSE OF COUNT IN aws_subnet a_web_subnets

#create internet gateway
resource "aws_internet_gateway" "a_igw" {
  vpc_id = aws_vpc.a_vpc.id

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-igw" })
}

#create aws routing table
resource "aws_route_table" "a_rt" {
  vpc_id = aws_vpc.a_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.a_igw.id
  }
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-rt" })
}

#associate aws routing table with public subnet
resource "aws_route_table_association" "a_rt_assoc_subnets" {
  count = var.aws_web_subnet_count #reusing the subnet count variable instead
  subnet_id      = aws_subnet.a_web_subnets[count.index].id
  route_table_id = aws_route_table.a_rt.id
}

#associate aws routing table with public subnet 2 >> REMOVED BECAUSE OF COUNT IN aws_route_table_association a_rt_assoc_subnets
*/
# Security group
resource "aws_security_group" "a_web_sg" {
  name        = "a_web_sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  //vpc_id      = aws_vpc.a_vpc.id
  vpc_id = module.aws_vpc.vpc_id

  ingress {
    description     = "HTTP from anywhere"
    from_port       = var.aws_tcp_80
    to_port         = var.aws_tcp_80
    protocol        = var.aws_protocol_tcp
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.a_web_lb_sg.id]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = var.aws_tcp_443
    to_port     = var.aws_tcp_443
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  # removing this for now as not required
  #not liking this, seems like a backdoor
  ingress {
    description = "SSH from GitHub Actions and my IP"
    from_port   = var.aws_tcp_22
    to_port     = var.aws_tcp_22
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
    /*cidr_blocks = concat(
      var.juli_public_ip, # my public IPs
      [
        "4.175.114.0/24", # GitHub Actions
        "13.64.0.0/11",   # GitHub Actions
        "20.0.0.0/8",     # GitHub Actions (Azure)
        "40.64.0.0/10",   # GitHub Actions (Azure)
      ]
    )*/
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-sg" })
}

resource "aws_security_group" "a_web_lb_sg" {
  name        = "a_web_lb_sg"
  description = "Allow HTTP  and HTTPS inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

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

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-lb-sg" })
}

#create virtual machine or aws_instance
resource "aws_instance" "a_web_servers" {
  ami           = data.aws_ami.linux.id
  instance_type = var.aws_instance_type
  #using modulo to distribute instances across total count of subnets in the event of more instances are provisioned
  #subnet_id     = aws_subnet.a_web_subnets[(count.index % var.aws_web_subnet_count)].id
  subnet_id                   = module.aws_vpc.public_subnets[(count.index % var.aws_web_subnet_count)]
  count                       = var.aws_web_server_count
  key_name                    = aws_key_pair.a_ec2_ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.a_web_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.a_allow_web_servers_s3_profile.name
  depends_on                  = [aws_iam_role_policy.a_allow_web_servers_s3_policy]
  user_data = <<-EOF
    ${file("./Templates/installpython.tpl")}
    ${templatefile("./Templates/startupscript2.tpl", {
  s3_bucket_name = module.aws_s3.s3_bucket_id
})}
  EOF

tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-a-web-servers${count.index + 1}" })
}

#create virtual machine or aws_instance >> REMOVED BECAUSE OF COUNT IN aws_instance a_web_servers



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