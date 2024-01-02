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
    project_chapter = "04.ecs"
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
  # checkov:skip=CKV_AWS_249: ADD REASON
  family                   = "cb-task-kw"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  # for valid values see https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html
  cpu                = 256
  memory             = 512
  task_role_arn      = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "cb-task"
      image     = "docker.io/library/hello-world:latest"
      essential = true
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = var.log_group_name,
          awslogs-region        = var.main_deployment_region,
          awslogs-stream-prefix = "ecs"
          # the log group must exist
          # awslogs-create-group = "false"
          # awslogs-datetime-format = "%Y-%m-%dT%H:%M:%S.%fZ"
          # awslogs-multiline-pattern = "^\\d{4
        }
      }
      # portMappings = [
      #   {
      #     containerPort = 80
      #     hostPort      = 80
      #   }
      # ]
    }
  ])
  tags = merge(local.ecs_chapter_tags, { Name = "hello-world-task-def" })
}
# This is our ECS service
resource "aws_ecs_service" "cb-service-hw" {
  name            = "cb-service-kw"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.cb-task-hw.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = var.ecs_service_subnet_ids
    security_groups  = var.ecs_service_security_group_ids
    assign_public_ip = false
  }

  # we do not need an LB, the service is expected to produce stdout "hello world" only
  # load_balancer {
  #   target_group_arn = var.alb_tg_arn
  #   container_name   = "cb-task"
  #   container_port   = 80
  # }
  tags = merge(local.ecs_chapter_tags, { Name = "hello-world-service" })
}
