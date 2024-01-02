variable "meta_tags" {
  type = map(string)
}

variable "kms_key_arn" {
  type    = string
  default = "you must pass this"
}

variable "log_group_name" {
  type    = string
  default = "you must pass this"
}

variable "ecs_service_subnet_ids" {
  type = list(string)
}

variable "ecs_service_security_group_ids" {
  type = list(string)
}

variable "main_deployment_region" {
  type    = string
  default = "eu-central-1"
}
