terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  # backend "s3" {
  #   bucket  = "{BUCKET-NAME}"
  #   key     = "{BUCKET-KEY}"
  #   region  = "ap-northeast-1"
  #   profile = "terraform"
  # }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}
