terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.38.0"
    }
  }

  backend "s3" {
    bucket = "file-share-website"
    key    = "terraform"
    region = "eu-central-1"
  }
}