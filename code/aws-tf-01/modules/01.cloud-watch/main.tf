# Everything we do we expect to produce monitoring logs and traces
# In this module we define the CloudWatch Resources and permissions to to this

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
  clodwatch_chapter_tags = merge(var.meta_tags, {
    project_chapter = "01.cloudwatch"
  })
}

# Need to create a role to allow for logging with flow logs
resource "aws_iam_role" "log_iam_role" {
  name                = var.log_iam_role
  assume_role_policy  = data.aws_iam_policy_document.assume_role_for_logging.json
  # we use the managed policy to log
  # managed_policy_arns = [data.aws_iam_policy.full_log_policy.arn]
  tags                = merge(local.clodwatch_chapter_tags, { Name = "log_iam_role" })
}

# This is a predefined role in AWS
# TODO for production: check if fewer permissions can be granted
# data "aws_iam_policy" "full_log_policy" {
#   name = "CloudWatchLogsFullAccess"
# }


data "aws_iam_policy_document" "log_policy_document" {
  # checkov:skip=CKV_AWS_111: TODO: check how to resolve in the future
    statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    #trivy:ignore:AVD-AWS-0057: TODO: check how to resolve in the future
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "allow_logging" {
  name   = "example"
  role   = aws_iam_role.log_iam_role.id
  policy = data.aws_iam_policy_document.log_policy_document.json
}

data "aws_iam_policy_document" "assume_role_for_logging" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

data "aws_caller_identity" "current" {}

# TODO
# We add CloudWatch logging at checkov suggestion
resource "aws_kms_key" "log_enc_key" {
  description             = "Our KMS key"
  deletion_window_in_days = 8
  enable_key_rotation     = true
  # TODO: is a single location sufficient? How to add multiple with variables?
  policy                  = <<POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "${data.aws_caller_identity.current.id}"
          },
          "Action": "kms:*",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Principal": { "Service": "logs.${var.cloudwatch_location_for_policy}.amazonaws.com" },
          "Action": [
            "kms:Encrypt*",
            "kms:Decrypt*",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:Describe*"
          ],
          "Resource": "*"
        }
      ]
    }
    POLICY
  tags                    = merge(local.clodwatch_chapter_tags, { Name = "log_enc_key" })
}

resource "aws_cloudwatch_log_group" "cloudwatch_destination_log_group" {
  name              = var.cloudwatch_destination_log_group
  kms_key_id        = aws_kms_key.log_enc_key.arn
  retention_in_days = 5
  tags              = merge(local.clodwatch_chapter_tags, { Name = "destination_log_group" })
}
