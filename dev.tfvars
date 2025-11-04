# DEV Environment Configuration
# Variables for the DEV environment

# Environment identifier
environment = "dev"

# AWS Region
#aws_region = "us-west-2"

# Naming and Tagging
aws_naming_prefix = "JSLearningLab-DEV"
aws_common_tags = {
  Owner       = "Juli"
  Project     = "AWS-TF"
  Environment = "dev"
}

# Still using micro type for dev
aws_instance_type    = "t2.micro"
aws_web_server_count = 2
aws_web_subnet_count = 2

# VPC Configuration
aws_vpc_cidr              = "10.0.0.0/16"
aws_vpc_enable_dns_hostnames = true
