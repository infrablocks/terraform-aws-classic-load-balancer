variable "region" {}
variable "vpc_cidr" {}
variable "availability_zones" {
  type = list(string)
}

variable "component" {}
variable "deployment_identifier" {}
variable "dependencies" {
  type = list(string)
}

variable "private_zone_id" {}
