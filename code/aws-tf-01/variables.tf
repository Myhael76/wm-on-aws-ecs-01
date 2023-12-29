variable "resources_prefix" {
  type    = string
  default = "pj01"
}


variable "main_deployment_region" {
  type    = string
  default = "eu-central-1"
}
variable "provided_meta_tags" {
  type = map(string)
  default = {
    "environment_type" = "development"
  }
}
