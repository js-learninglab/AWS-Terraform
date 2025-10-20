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
  default     = 1
}

variable "environment" {
  description = "The environment for the deployment (e.g., dev, staging, prod)"
  type        = string
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