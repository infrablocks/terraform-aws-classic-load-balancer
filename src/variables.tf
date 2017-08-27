variable "region" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}

variable "component" {}
variable "deployment_identifier" {}

variable "listeners" {
  type = "list"
}

variable "health_check_target" {
  default = "TCP:80"
}
variable "health_check_timeout" {
  default = 5
}
variable "health_check_interval" {
  default = 30
}
variable "health_check_unhealthy_threshold" {
  default = 2
}
variable "health_check_healthy_threshold" {
  default = 10
}

variable "enable_cross_zone_load_balancing" {
  default = "yes"
}

variable "enable_connection_draining" {
  default = "no"
}
variable "connection_draining_timeout" {
  default = 300
}

variable "idle_timeout" {
  default = 60
}

variable "expose_to_public_internet" {
  default = "no"
}
