provider "aws" {
  region = var.region
}

terraform {
  required_version = ">=v1.12.2"

  required_providers {
    aws = {
      source = "hashicorp/aws"
        version = ">= 6.3.0"
    }
  }

  backend "s3" {
    bucket         = "sandbox-terraform-state-bucket"
    key            = "TF_State/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "tf-lock-table"
    encrypt        = true
  }
}
