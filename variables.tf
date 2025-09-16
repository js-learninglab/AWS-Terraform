variable "AWS_APP_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "AWP-APP-terraform"
}

variable "AWS_DB_instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "AWP-DB-terraform"
}

variable "AWS_instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "AWS_app_server_count" {
  description = "number of app_server instances"
  default = 2
}

variable "AWS_db_server_count" {
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