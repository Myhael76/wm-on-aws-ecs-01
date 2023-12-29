variable "resources_prefix" {
  type    = string
  default = "pj01"
}

variable "provided_meta_tags" {
  type = map(string)
  default = {
    "environment_type" = "development"
  }
}
