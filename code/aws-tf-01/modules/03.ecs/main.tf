## Module ecs - Elastic Container Services
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
  ecs_chapter_tags = merge(var.meta_tags, {
    project_chapter = "03.ecs"
  })
}

resource "aws_ecs_cluster" "main" {
  # checkov:skip=CKV_AWS_65: CI TEMP, to remove
  name = "cb-cluster"

  tags = local.ecs_chapter_tags
}
