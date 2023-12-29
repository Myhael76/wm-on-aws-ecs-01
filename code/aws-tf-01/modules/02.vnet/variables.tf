variable "meta_tags" {}

variable "vnet_properties" {
  type = object({
    cidr_block       = string
    main_subnet_name = string
  })
  default = {
    cidr_block       = "10.0.0.0/16"
    main_subnet_name = "sn01"
  }
}

variable "our_log_iam_role_arn" {
  type    = string
  default = "you must set this"
}

variable "our_cloudwatch_log_group_arn" {
  type    = string
  default = "you must set this"
}
