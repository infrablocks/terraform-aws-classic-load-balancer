variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "vpc_cidr" {}
variable "availability_zones" {
  type = list(string)
}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}
