variable "our_resources_prefix" {
  type    = string
  default = "pj01"
}

variable "provided_meta_tags" {
  #type = {}
  default = {
    "environment_type" = "development"
  }
}
