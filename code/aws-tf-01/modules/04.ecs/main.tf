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

# ECS scheduled tasks can be created using EventBridge, see https://github.com/terraform-aws-modules/terraform-aws-eventbridge/blob/master/examples/with-ecs-scheduling/main.tf
module "eventbridge" {
  source     = "git::https://github.com/terraform-aws-modules/terraform-aws-eventbridge.git?ref=6d2d61d7ec5781563648937319d018b01d4ddfe6" # commit hash of version 3.0.0
  create_bus = false
  bus_name   = "default"

  create_role       = true
  role_name         = "ecs-eventbridge-scheduler-role"
  attach_ecs_policy = true
  ecs_target_arns   = [aws_ecs_task_definition.cb-task-hw.arn]

  tags = merge(local.ecs_chapter_tags, { subchapter = "04.01 eventbridge module" })

  # Fire every five minutes
  rules = {
    hwsched = {
      description         = "Cron for Hello World"
      enabled             = true
      schedule_expression = "rate(20 minutes)"
    }
  }

  # Send to a fargate ECS cluster
  targets = {
    hwsched = [
      {
        name            = "Hello World Scheduler"
        arn             = aws_ecs_cluster.main.arn
        attach_role_arn = true

        ecs_target = {
          # If a capacity_provider_strategy specified, the launch_type parameter must be omitted.
          # launch_type         = "FARGATE"
          task_count              = 1
          task_definition_arn     = aws_ecs_task_definition.cb-task-hw.arn
          enable_ecs_managed_tags = true

          network_configuration = {
            assign_public_ip = false
            subnets          = var.ecs_service_subnet_ids
            security_groups  = var.ecs_service_security_group_ids
          }

          # If a capacity_provider_strategy is specified, the launch_type parameter must be omitted.
          # If no capacity_provider_strategy or launch_type is specified, the default capacity provider strategy for the cluster is used.
          capacity_provider_strategy = [
            {
              capacity_provider = "FARGATE"
              base              = 1
              weight            = 100
            },
            {
              capacity_provider = "FARGATE_SPOT"
              weight            = 100
            }
          ]
        }
      }
    ]
  }
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

  capacity_providers = ["FARGATE_SPOT", "FARGATE"]

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
# resource "aws_ecs_service" "cb-service-hw" {
#   name            = "cb-service-kw"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.cb-task-hw.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"

#   network_configuration {
#     subnets          = var.ecs_service_subnet_ids
#     security_groups  = var.ecs_service_security_group_ids
#     assign_public_ip = false
#   }

#   # we do not need an LB, the service is expected to produce stdout "hello world" only
#   # load_balancer {
#   #   target_group_arn = var.alb_tg_arn
#   #   container_name   = "cb-task"
#   #   container_port   = 80
#   # }
#   tags = merge(local.ecs_chapter_tags, { Name = "hello-world-service" })
# }

#resource "aws_ecs_shceduled_task"
