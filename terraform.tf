terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }

    random = {
      source = "hashicorp/random"
      version = "~> 3.5"
    }
  }
  required_version = ">= 1.2"
}