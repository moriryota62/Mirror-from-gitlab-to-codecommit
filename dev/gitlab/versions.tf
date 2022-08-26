terraform {
  required_version = ">= 1.0.10"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      pj    = "mirror"
      env   = "dev"
      owner = "mori"
    }
  }
}