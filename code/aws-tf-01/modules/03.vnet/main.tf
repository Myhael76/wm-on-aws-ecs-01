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
    project_chapter = "03.networking"
  })
}

# Service VPC 01
resource "aws_vpc" "service-vpc-01" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(local.vnet_chapter_tags, { Name = "service-vpc-01" })
}

# Main Service subnet
resource "aws_subnet" "service-vpc-01-subnet-01" {
  # This subnet is intended as a "public" subnet according to AWS base concepts

  vpc_id     = aws_vpc.service-vpc-01.id
  cidr_block = "10.0.1.0/24"
  tags       = merge(local.vnet_chapter_tags, { Name = "service-vpc-01-subnet-01" })
}

# We need to a flow log to log what is happening in the vnet into our CloudWatch log destination
resource "aws_flow_log" "vpc-01-flow-log" {
  iam_role_arn    = var.log_iam_role_arn
  log_destination = var.cloudwatch_log_group_arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.service-vpc-01.id
  tags            = merge(local.vnet_chapter_tags, { Name = "vpc-01-flow-log" })
}

############### Network Security Group (can we reuse for more VPCs?)
resource "aws_default_security_group" "default_vpc-01-sg" {
  vpc_id = aws_vpc.service-vpc-01.id
  tags   = merge(local.vnet_chapter_tags, { Name = "default_vpc-01-sg" })
}

resource "aws_security_group" "vpc-01-sg-01" {
  # checkov:skip=CKV2_AWS_5: False positive, this is associated to ECS services in another module.connection 
  # see https://github.com/bridgecrewio/checkov/issues/1203#issuecomment-1873836090

  name        = "vpc-01-sg-01"
  description = "Allow network communications"
  vpc_id      = aws_vpc.service-vpc-01.id

  # ingress {
  #   description = "SSH"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Allow outbound 443 port, usually used for https"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.vnet_chapter_tags, { Name = "vpc-01-sg-01" })
}

# We need an internet gateway to access internet from our containers, e.g. to pull public images
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.service-vpc-01.id
  tags   = merge(local.vnet_chapter_tags, { Name = "internet gateway" })
}

# Route the traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.service-vpc-01.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}
