variable "instance_name" {
  description = "Value of the EC2 instance's Name tag."
  type        = string
  default     = "learn-terraform"
}

variable "instance_type" {
  description = "The EC2 instance's type."
  type        = string
  default     = "t2.micro"
}

variable "app_server_count" {
  description = "number of app_server instances"
  default = 2
}

variable "db_server_count" {
  description = "number of db_server instances"
  default = 2
}