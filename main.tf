terraform {
  required_version = "1.9.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
  # backend "s3" {
  #   bucket = "my-first-bucket-80"
  #   region = "us-east-2"
  #   key = "terraform/terraform.tfstate"
  # }
}

provider "aws" {
  region = "us-east-2"
}

module "webserver" {
  source = "./module"
}


