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

# This is our ECS cluster
resource "aws_ecs_cluster" "main" {
  # checkov:skip=CKV_AWS_65: CI TEMP, to remove
  name = "cb-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      kms_key_id = var.kms_key_arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = var.log_group_name
      }
    }
  }

  tags = merge(local.ecs_chapter_tags, { Name = "cb-cluster" })
}

# The cluster needs capacity
resource "aws_ecs_cluster_capacity_providers" "cb-cluster-capacity" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE_SPOT"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE_SPOT"
  }
}

# This is our ECS task definition
resource "aws_ecs_task_definition" "cb-task-hw" {
  family                   = "cb-task-kw"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  # for valid values see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu                      = 256
  memory                   = 512
  #execution_role_arn       = var.ecs_task_execution_role_arn
  container_definitions = jsonencode([
    {
      name      = "cb-task"
      image     = "hello-world"
      essential = true
      # portMappings = [
      #   {
      #     containerPort = 80
      #     hostPort      = 80
      #   }
      # ]
    }
  ])
}
