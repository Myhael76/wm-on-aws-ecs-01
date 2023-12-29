variable "meta_tags" {}

variable "our_log_iam_role" {
  type    = string
  default = "our_log_iam_role"
}

variable "cloudwatch_destination_log_group" {
  type    = string
  default = "logs_destination"
}
