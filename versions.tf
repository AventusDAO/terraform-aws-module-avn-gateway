terraform {
  required_version = ">= 1.3.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.0"
    }
  }
}
