## Module vnet - virtual networking and related fundamentals
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
  vnet_chapter_tags = merge(var.meta_tags, {
    project_chapter = "02.networking"
  })
}

# Service VPC 01
resource "aws_vpc" "service-vpc-01" {
  cidr_block = "10.0.0.0/16"
  tags       = local.vnet_chapter_tags
}

# Main Service subnet
resource "aws_subnet" "service-vpc-01-subnet-01" {
  vpc_id     = aws_vpc.service-vpc-01.id
  cidr_block = "10.0.1.0/24"
  tags       = local.vnet_chapter_tags
}

############### CloudWatch logging

# TODO
# # We add CloudWatch logging at checkov suggestion
# resource "aws_kms_key" "our_kms_key" {
#   # checkov:skip=CKV_AWS_7: ADD REASON
#   description             = "Our KMS key"
#   deletion_window_in_days = 8
# }


# We need to a flow log to log what is happening in the vnet into our CloudWatch log destination
resource "aws_flow_log" "vpc-01-flow-log" {
  iam_role_arn    = var.our_log_iam_role_arn
  log_destination = var.our_cloudwatch_log_group_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.service-vpc-01.id
  tags            = local.vnet_chapter_tags
}

############### Network Security Group (can we reuse for more VPCs?)
resource "aws_default_security_group" "aws-tf-01-sg" {
  vpc_id = aws_vpc.service-vpc-01.id
  tags   = local.vnet_chapter_tags
}
