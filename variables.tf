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

variable "aws_region" {
  type        = string
  default     = "us-west-2"
  description = "AWS us-west-2 region"
}
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
#####################
####AWS Variables####
#####NETWORKING######

variable "aws_vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_vpc_public_subnets" {
  description = "A list of CIDR blocks for the public subnets."
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "aws_vpc_azs" {
  description = "A list of availability zones in the region."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "aws_vpc_private_subnets" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24","10.0.4.0/24"]
}

variable "aws_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
}

variable "aws_web_http_port" {
  description = "The HTTP port for the web server security group."
  type        = number
  default     = 80
}

#####Resources#####

variable "aws_app_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "aws-app-terraform"
}

variable "aws_db_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "aws-db-terraform"
}

variable "aws_instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t3.micro"
}

variable "aws_app_server_count" {
  description = "number of app_server instances"
  default     = 1
}

variable "aws_db_server_count" {
  description = "number of db_server instances"
  default     = 1
}

variable "aws_web_server_count" {
  description = "number of web_server instances"
  default     = 2
}

variable "aws_tags_owner" {
  description = "The owner tag for resources."
  type        = string
  default     = "js.learninglab"
}

variable "aws_tags_environment" {
  description = "The environment tag for resources."
  type        = string
  default     = "Dev"
}

variable "aws_tags_project" {
  description = "The project tag for resources."
  type        = string
  default     = "Learning Terraform"
}

#####################
####GCP Variables####
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
  default     = 1
}

variable "gcp_db_server_count" {
  description = "number of db_server instances"
  default     = 1
}