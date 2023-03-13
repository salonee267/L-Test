terraform {
  
  required_version = ">= 0.12.24"
  
  backend "s3" {
    bucket = "bucketforbackendstate-prod"
    key    = "bucketforbackendstate-prod.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
}
