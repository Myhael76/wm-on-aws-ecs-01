variable "meta_tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    "project" = "terraform-aws-log-destination"
    "env"     = "dev"
    "owner"   = "terraform"

  }
}

variable "log_iam_role" {
  type    = string
  default = "log_iam_role"
}

variable "cloudwatch_destination_log_group" {
  type    = string
  default = "logs_destination"
}

variable "cloudwatch_location_for_policy"{
  type = string
  default = "eu-central-1"
}
