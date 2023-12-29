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

resource "aws_iam_role" "our_log_iam_role" {
  name                = var.our_log_iam_role
  assume_role_policy  = data.aws_iam_policy_document.log_policy_document.json
  managed_policy_arns = [data.aws_iam_policy.log_policy.arn]
  tags                = merge(local.clodwatch_chapter_tags, { Name = "log_iam_role" })
}

# This is a predefined role in AWS
# TODO for production: check if fewer permissions can be granted
data "aws_iam_policy" "log_policy" {
  name = "CloudWatchLogsFullAccess"
}

data "aws_iam_policy_document" "log_policy_document" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
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
        }
      ]
    }
    POLICY
  tags                    = merge(local.clodwatch_chapter_tags, { Name = "log_enc_key" })
}

resource "aws_cloudwatch_log_group" "cloudwatch_destination_log_group" {
  name              = var.cloudwatch_destination_log_group
  retention_in_days = 5
  tags              = merge(local.clodwatch_chapter_tags, { Name = "destination_log_group" })
  kms_key_id        = aws_kms_key.log_enc_key.id
}
