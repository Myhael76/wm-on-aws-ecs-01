variable "meta_tags" {
  type = map(string)
}

variable "log_iam_role_arn" {
  type    = string
  default = "you must set this"
}

variable "cloudwatch_log_group_arn" {
  type    = string
  default = "you must set this"
}
