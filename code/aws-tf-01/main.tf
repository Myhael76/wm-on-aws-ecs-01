terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
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
