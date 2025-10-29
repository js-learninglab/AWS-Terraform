terraform {
  
  required_version = ">= 1.2"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    # adding random provider to generate random strings/integers for S3 bucket ID
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

    cloud {
        #organisation ID
        organization = "js_learninglab_hcp"

        #workspace ID
        workspaces {
            name = "js_learninglab_backend"
        }
    }

}