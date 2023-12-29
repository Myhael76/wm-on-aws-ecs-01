variable "meta_tags" {
  description = "Tags to be added to all resources"
  type        = map(string)
  default = {
    "project" = "terraform-aws-log-destination"
    "env"     = "dev"
    "owner"   = "terraform"

  }
}

variable "cloudwatch_destination_log_group" {
  type    = string
  default = "logs_destination"
}

variable "main_key_pair_arn"{
  type = string
  default = "You must provide this"
}
