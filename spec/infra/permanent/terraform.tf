terraform {
  required_version = ">= 0.14"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.29"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2"
    }
  }
}