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
# Supporting one region for now. TODO: check if we can generalize
provider "aws" {
  alias  = "aws-main-region"
  region = var.deployment_regions_list[0]
}


#### Project resources are tagged with the following computed tags and groupped in the below resource group for convenience
#### Each submodule isolates a "concern" and works like a "chapter" of our story
locals {

  meta_tags = merge(var.provided_meta_tags,
    {
      project_name        = "${var.resources_prefix}_project"
      resource_group_name = "${var.resources_prefix}_rg"
    }
  )
}

# Story index -> Project Resource Group allows for quick navigation and control of all our resources
resource "aws_resourcegroups_group" "resource_group" {
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

# Story chapter #1 -> Project security
module "sec" {
  source = "./modules/01.security"
  providers = {
    aws = aws.aws-main-region
  }

  # Variables
  deployment_regions_list = var.deployment_regions_list
  meta_tags               = local.meta_tags

}
# Story chapter #2 -> Project observability using CloudWatch
module "cw" {
  source = "./modules/02.cloud-watch"
  providers = {
    aws = aws.aws-main-region
  }

  # Variables
  main_key_pair_arn = module.sec.main_key_pair_arn
  meta_tags         = local.meta_tags
}

# Story chapter #2 -> All AWS resources live in a network arrangmenet of sorts
module "vnet" {
  source = "./modules/03.vnet"
  providers = {
    aws = aws.aws-main-region
  }

  # Variables
  #vnet_properties              = merge(vnet.vnet_properties, { "main_subnet_name" = "sn02" })
  log_iam_role_arn         = module.sec.logger_artifact_role_arn
  cloudwatch_log_group_arn = module.cw.log_destination_arn

  meta_tags = local.meta_tags
}

# Story chapter #3 -> Adding ECS to the mix
module "ecs" {
  source = "./modules/04.ecs"
  providers = {
    aws = aws.aws-main-region
  }

  # Variables
  kms_key_arn                    = module.sec.main_key_pair_arn
  log_group_name                 = module.cw.log_group_name
  ecs_service_subnet_ids         = module.vnet.ecs_service_subnet_ids
  ecs_service_security_group_ids = module.vnet.ecs_service_security_group_ids
  #main_deployment_region         = var.main_deployment_region
  meta_tags = local.meta_tags
}
