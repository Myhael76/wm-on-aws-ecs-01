## Module vnet - virtual networking and related fundamentals
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6"
}

locals {
  vnet_chapter_tags = merge(var.meta_tags, {
    project_chapter = "03.networking"
  })
}
