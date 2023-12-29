variable "meta_tags" {
  type = map(string)
}

variable "our_log_iam_role_arn" {
  type    = string
  default = "you must set this"
}

variable "our_cloudwatch_log_group_arn" {
  type    = string
  default = "you must set this"
}
