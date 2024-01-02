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
  security_chapter_tags = merge(var.meta_tags, {
    project_chapter = "01.security"
  })
}

data "aws_caller_identity" "current" {}
