variable "meta_tags" {
  type = map(string)
}

variable "kms_key_arn"{
  type = string
  default = "you must pass this"
}


variable "log_group_name"{
  type = string
  default = "you must pass this"
}
