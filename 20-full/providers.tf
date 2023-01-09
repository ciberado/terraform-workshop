terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.45"
    }
  }
}

provider "aws" {
  region  = "${var.region}"


  default_tags {
    tags = {
      Project = "SimpleArchFullExample"
      Environment : terraform.workspace
      Creation : timestamp()
    }
  }  
}
