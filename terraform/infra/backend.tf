terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
  backend "s3" {
    bucket = "gettrx-bucket"
    key    = "tfstate"
    region = "us-east-1"
  }
}