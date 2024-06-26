terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.region
}

module "ec2" {
  source           = "../../components/aws/ec2"
  environment      = var.environment
  instance_type    = var.instance_type
  key_name         = var.key_name
}

module "emr" {
  source           = "../../components/aws/emr"
  environment      = var.environment
  key_name         = var.key_name
}

module "s3" {
  source      = "../../components/aws/s3"
  bucket_name = "data-analysis-ecommerce-bucket"
  environment      = var.environment
}