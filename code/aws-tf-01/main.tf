terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.6"
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-central-1"
}

# Service VPC 01
resource "aws_vpc" "service-vpc-01" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "service-vpc-01-subnet-01" {
  vpc_id     = aws_vpc.service-vpc-01.id
  cidr_block = "10.0.1.0/24"
}

# ############### CloudWatch logging
# # We add CloudWatch logging at checkov suggestion
# resource "aws_kms_key" "our_kms_key" {
#   # checkov:skip=CKV_AWS_7: ADD REASON
#   description             = "Our KMS key"
#   deletion_window_in_days = 8
# }

resource "aws_flow_log" "vpc-01-flow-log" {
  iam_role_arn    = aws_iam_role.our_log_iam_role.arn
  log_destination = aws_cloudwatch_log_group.our_cloudwatch_log_group.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.service-vpc-01.id
}

resource "aws_cloudwatch_log_group" "our_cloudwatch_log_group" {
  # checkov:skip=CKV_AWS_158: ADD REASON
  name = "our_cloudwatch_log_group"
  #kms_key_id        = aws_kms_key.our_kms_key.id
  retention_in_days = 5
}

resource "aws_iam_role" "our_log_iam_role" {
  name               = "our_log_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_logger_role.json
}

data "aws_iam_policy" "log_policy" {
  provider = aws.destination
  name     = "CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "assume_logger_role" {
  provider            = aws.destination
  name                = "assume_logger_role"
  assume_role_policy  = data.aws_iam_policy_document.assume_role.json
  managed_policy_arns = [data.aws_iam_policy.log_policy.arn]
}


# data "aws_caller_identity" "current" {}

# data "aws_iam_policy_document" "log_policy" {
#   checkov:skip=CKV_AWS_111: Do not have sensibility about why this is wrong ATM
#   statement {
#     effect = "Allow"

#     actions = [
#       "logs:*",
#       "cloudwatch:GenerateQuery"
#     ]

#     principals {
#       type        = "AWS"
#       identifiers = [data.aws_caller_identity.current.id]
#     }

#     resources = ["*"]
#   }
# }

############### Network Security Group (can we reuse for more VPCs?)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.service-vpc-01.id
}
