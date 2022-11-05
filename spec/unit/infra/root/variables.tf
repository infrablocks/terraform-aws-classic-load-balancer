variable "region" {}

variable "component" {}
variable "deployment_identifier" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "listeners" {
  type = list(object({
    lb_port: number
    lb_protocol: string
    instance_port: number
    instance_protocol: string
    ssl_certificate_id: string
  }))
}
variable "access_control" {
  type = list(object({
    lb_port: number
    instance_port: number
    allow_cidrs: list(string)
  }))
  default = null
}

variable "egress_cidrs" {
  type = list(string)
  default = null
}

variable "health_check_target" {
  default = null
}
variable "health_check_timeout" {
  default = null
}
variable "health_check_interval" {
  default = null
}
variable "health_check_unhealthy_threshold" {
  default = null
}
variable "health_check_healthy_threshold" {
  default = null
}

variable "enable_cross_zone_load_balancing" {
  default = null
}

variable "enable_connection_draining" {
  default = null
}
variable "connection_draining_timeout" {
  default = null
}

variable "idle_timeout" {
  default = null
}

variable "include_public_dns_record" {
  default = null
}
variable "include_private_dns_record" {
  default = null
}

variable "expose_to_public_internet" {
  default = null
}
