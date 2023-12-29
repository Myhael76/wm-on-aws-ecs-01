variable "meta_tags" {}

variable "our_log_iam_role" {
  type    = string
  default = "our_log_iam_role"
}

variable "our_cloudwatch_log_group" {
  type    = string
  default = "our_cloudwatch_log_group"
}
