#####################
#####Credentials#####
#####################
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
}

variable "aws_region" {
  type = string
  default = "us-west-2"
  description = "AWS us-west-2 region"
}

variable "gcp_credentials" {
  type = string
  #credentials = file("C:/Cloud study/GCP-Terraform/GCP-terraform-471706-1f7e4f5f6f7e.json")
  description = "GCP credentials"
  sensitive = true
  #setting this variable by pointing to credential file just to be different from aws
}

variable "gcp_region" {
  type = string
  default = "us-west1"
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

variable "aws_vpc_azs" {
  description = "A list of availability zones in the region."
  type        = list(string)
  default     = ["us-west-2a", "us-west-2b", "us-west-2c"]
}

variable "aws_vpc_private_subnets" {
  description = "A list of CIDR blocks for the private subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "aws_dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC."
  type        = bool
  default     = true
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
  default     = "t2.micro"
}

variable "aws_app_server_count" {
  description = "number of app_server instances"
  default = 2
}

variable "aws_db_server_count" {
  description = "number of db_server instances"
  default = 2
}

#gcp Variables
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

variable "gcp_app_server_count" {
  description = "number of app_server instances"
  default = 2
}

variable "gcp_db_server_count" {
  description = "number of db_server instances"
  default = 2
}