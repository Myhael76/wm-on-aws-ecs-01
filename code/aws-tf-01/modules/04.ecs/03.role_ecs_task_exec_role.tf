# Role for ECS task execution

## Allow the service running ecs tasks to work by assuming the role we define here
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "scheduler.amazonaws.com"
        }
      }
    ]
  })
  tags = merge(local.ecs_chapter_tags, { Name = "ecs_task_execution_role" })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# # Attach permissions to create log streams and related log events
# resource "aws_iam_role_policy" "allow_logging_for_logger_artifact" {
#   name   = "allow_logging"
#   role   = aws_iam_role.ecs_task_execution_role.id
#   policy = data.aws_iam_policy_document.allow_logging_policy_document.json
# }

# # Allow creation of logging artifacts and entries
# data "aws_iam_policy_document" "allow_logging_policy_document" {
#   # checkov:skip=CKV_AWS_111: TODO: check how to resolve in the future
#   statement {
#     effect = "Allow"
#     actions = [
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#     ]

#     #trivy:ignore:AVD-AWS-0057: TODO: check how to resolve in the future
#     resources = ["*"]
#   }
# }
