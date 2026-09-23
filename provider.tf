terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "astro-terraform-state-685306736016"
    key            = "astro-app/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "astro-tf-lock"
    encrypt        = true
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}