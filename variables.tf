#####################
#####Credentials#####
#####################
/*
variable "aws_access_key" {
  type = string
  #access_key = "AKIAVC6Z7YLRPWISHIZR"
  description = "AWS access key"
  sensitive =  true
}

variable "aws_secret_key" {
  type = string
  #secret_key = "7ucvDQOrPZIuU/Y8ZEH7wpp3akvWDJKBufB215U5"
  description = "AWS secret key"
  sensitive =  true
  #credentials are specified in $env
}
*/

/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/
variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS us-west-2 region"
}

variable "environment" {
  description = "Environment identifier"
  type        = string
  default     = "dev"
}

#####NETWORKING######



#####Resources#####

variable "aws_web_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "aws-web-terraform"
}

variable "aws_instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "aws_web_server_count" {
  description = "number of web_server instances"
  type        = number
  default     = 2
}

variable "aws_web_subnet_count" {
  description = "number of aws web subnets"
  type        = number
  default     = 2
}

variable "asg_aws_server_count_desired" {
  description = "number of aws autoscaling group instances desired"
  type        = number
  default     = 2
}

variable "asg_aws_server_count_min" {
  description = "number of aws autoscaling group instances min"
  type        = number
  default     = 1
}

variable "asg_aws_server_count_max" {
  description = "number of aws autoscaling group instances max"
  type        = number
  default     = 4
}

variable "aws_vpc_cidr" {
  description = "The cidr for the AWS VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "juli_public_ip" {
  description = "a list of my public IP addresses for SSH access"
  type        = list(string)
  default     = ["167.103.62.209/32"]
}

#this is now redundant because of cidrsubnet function is used dynamically to create subnets
/*
variable "aws_vpc_web_subnets_cidrs" {
  description = "The cidr for the AWS VPC web subnet."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
*/

variable "aws_us_west_regions" {
  description = "The availability zone for the AWS resources."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "aws_protocol_tcp" {
  description = "The TCP protocol."
  type        = string
  default     = "tcp"
}

variable "aws_tcp_22" {
  description = "The TCP port 22 for SSH."
  type        = number
  default     = 22
}

variable "aws_tcp_80" {
  description = "The TCP port 80 for HTTP."
  type        = number
  default     = 80
}

variable "aws_tcp_443" {
  description = "The TCP port 443 for HTTPS."
  type        = number
  default     = 443
}

variable "aws_tcp_3000" {
  description = "The TCP port 3000 for Grafana UI."
  type        = number
  default     = 3000
}

variable "aws_tcp_9090" {
  description = "The TCP port 9090 for Prometheus UI."
  type        = number
  default     = 9090
}

variable "aws_tcp_9100" {
  description = "The TCP port 9100 for Prometheus to scrape metrics."
  type        = number
  default     = 9100
}

variable "aws_tcp_all" {
  description = "All TCP ports."
  type        = string
  default     = "0"
}

variable "aws_vpc_enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "aws_common_tags" {
  description = "Common tag Project for all AWS resources."
  type        = map(string)
  default = {
    Owner   = "Juli"
    Project = "AWS-TF"
  }
}

variable "aws_naming_prefix" {
  description = "Naming prefix for all resources"
  type        = string
  default     = "JSLearningLab"
}

variable "aws_s3_bucket_name" {
  description = "The name of the S3 bucket."
  type        = string
  default     = "S3storage"
}

variable "elb_service_account_arn" {
  description = "The AWS ELB service account ARN."
  type        = string
  default     = "arn:aws:iam::127311923021:root"
}

variable "common_tags" {
  description = "Common tag Project for all resources."
  type        = map(string)
  default     = {}
}

variable "ec2_ssh_public_key" {
  description = "Public key for SSH access to EC2 instances."
  type        = string
  sensitive   = true
}

variable "aws_rds_db_name" {
  description = "The name of the RDS database."
  type        = string
  default     = "jslearninglabdb"
}

variable "aws_rds_master_username" {
  description = "The master username for the RDS database."
  type        = string
  default     = "JSDBadmin"
}

variable "aws_rds_allocated_storage" {
  description = "The allocated storage for the RDS database in GB."
  type        = number
  default     = 20
}

variable "aws_rds_engine" {
  description = "The database engine for the RDS instance."
  type        = string
  default     = "postgres"
}

variable "aws_rds_engine_version" {
  description = "The database engine version for the RDS instance."
  type        = string
  default     = "15"
}

variable "aws_rds_instance_class" {
  description = "The instance class for the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "aws_rds_backup_retention_period" {
  description = "The backup retention period for the RDS instance in days."
  type        = number
  default     = 7
}

/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/

/*
variable "gcp_credentials" {
  type = string
  #credentials = file("C:/Cloud study/GCP credentials/gcp-credentials.json")
  description = "GCP credentials"
  sensitive = true
  #setting this variable by pointing to credential file just to be different from aws
  #credentials are specified in $env
}
*/

variable "gcp_region" {
  type        = string
  default     = "us-west1"
  description = "GCP us-west1 region"
}

#####NETWORKING######

#gcp network module doesn't require huge cidr block unlike aws

variable "gcp_vpc_subnets" {
  description = "The cidr for the GCP VPC subnet."
  type        = list(string)
  default     = ["11.0.1.0/24", "11.0.2.0/24"]
}

variable "gcp_vpc_region" {
  description = "The region for the GCP VPC."
  type        = string
  default     = "us-west1"
}

#####Resources#####

variable "gcp_app_instance_name" {
  description = "value of the compute engine's name"
  type        = string
  default     = "gcp-app-terraform"
}

variable "gcp_db_instance_name" {
  description = "value of the compute engine's name"
  type        = string
  default     = "gcp-db-terraform"
}

variable "gcp_instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "gcp_image_family" {
  description = "The image family of the operating system to use."
  type        = string
  default     = "windows-cloud/windows-2022"
}

variable "gcp_image_project" {
  description = "The project where the image family belongs."
  type        = string
  default     = "windows-cloud"
}

variable "gcp_boot_disk_size" {
  description = "The size of the boot disk in GB."
  type        = number
  default     = 20
}

variable "gcp_app_server_count" {
  description = "number of app_server instances"
  default     = 0
}

variable "gcp_db_server_count" {
  description = "number of db_server instances"
  default     = 0
}