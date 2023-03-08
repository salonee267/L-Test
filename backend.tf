terraform {
  
  required_version = ">= 0.12.24"
  
  backend "s3" {
    bucket = "bucketforbackendstate"
    key    = "bucketforbackendstate.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  region  = "eu-west-1"
}
