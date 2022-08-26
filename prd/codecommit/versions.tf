terraform {
  required_version = ">= 1.0.10"

  required_providers {
    aws = {
      version = "= 3.70.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      pj    = "mirror"
      env   = "prd"
      owner = "mori"
    }
  }
}