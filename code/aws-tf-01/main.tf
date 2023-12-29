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
  alias  = "aws-frankfurt"
  region = "eu-central-1"
}

#### Project resources are tagged with the following computed tags and groupped in the below resource group for convenience
#### Each submodule isolates a "concern" and works like a "chapter" of our story
locals {
  meta_tags = merge(var.provided_meta_tags,
    {
      project_name        = "${var.our_resources_prefix}_project"
      resource_group_name = "${var.our_resources_prefix}_rg"
    }
  )
}

# Story index -> Project Resource Group allows for quick navigation and control of all our resources
resource "aws_resourcegroups_group" "our_resource_group" {
  name = local.meta_tags.resource_group_name
  tags = merge(local.meta_tags, { "Name" = local.meta_tags.resource_group_name })

  resource_query {
    query = <<JSON
      {
        "ResourceTypeFilters": [
          "AWS::AllSupported"
        ],
        "TagFilters": [
          {
            "Key": "resource_group_name",
            "Values": ["${local.meta_tags.resource_group_name}"]
          }
        ]
      }
      JSON
  }
}

# Story chapter #1 -> Project observability using CloudWatch
module "cw" {
  source = "./modules/01.cloud-watch"
  providers = {
    aws = aws.aws-frankfurt
  }

  # Variables
  meta_tags = local.meta_tags
}

# Story chapter #2 -> All AWS resources live in a network arrangmenet of sorts
module "vnet" {
  source = "./modules/02.vnet"
  providers = {
    aws = aws.aws-frankfurt
  }

  # Variables
  #vnet_properties              = merge(vnet.vnet_properties, { "main_subnet_name" = "sn02" })
  our_log_iam_role_arn         = module.cw.our_log_iam_role_arn
  our_cloudwatch_log_group_arn = module.cw.our_log_destination_arn

  meta_tags = local.meta_tags
}

# Story chapter #3 -> Adding ECS to the mix
module "ecs" {
  source = "./modules/03.ecs"
  providers = {
    aws = aws.aws-frankfurt
  }

  # Variables
  meta_tags = local.meta_tags
}
