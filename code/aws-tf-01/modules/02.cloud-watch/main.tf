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
  cloudwatch_chapter_tags = merge(var.meta_tags, {
    project_chapter = "02.cloudwatch"
  })
}

resource "aws_cloudwatch_log_group" "cloudwatch_destination_log_group" {
  name              = var.cloudwatch_destination_log_group
  kms_key_id        = var.main_key_pair_arn
  retention_in_days = 5
  tags              = merge(local.cloudwatch_chapter_tags, { Name = "destination_log_group" })
}
