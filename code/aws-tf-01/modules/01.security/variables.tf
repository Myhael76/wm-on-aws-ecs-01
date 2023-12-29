variable "meta_tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    "project" = "terraform-aws-log-destination"
    "env"     = "dev"
    "owner"   = "terraform"

  }
}

variable "logger_artifact_role_name" {
  type = string
  default = "logger_artifact_role"
}

variable "deployment_regions_list"{
  type = list(string)
  default = ["eu-central-1"]
}
