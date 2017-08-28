variable "region" {}
variable "vpc_cidr" {}
variable "availability_zones" {}

variable "component" {}
variable "deployment_identifier" {}
variable "dependencies" {}

variable "bastion_ami" {}
variable "bastion_instance_type" {}
variable "bastion_ssh_public_key_path" {}
variable "bastion_ssh_allow_cidrs" {}

variable "domain_name" {}
variable "public_zone_id" {}
variable "private_zone_id" {}

variable "infrastructure_events_bucket" {}

variable "listeners" {
  type = "list"
}
variable "access_control" {
  type = "list"
}

variable "egress_cidrs" {
  type = "list"
}

variable "health_check_target" {}
variable "health_check_timeout" {}
variable "health_check_interval" {}
variable "health_check_unhealthy_threshold" {}
variable "health_check_healthy_threshold" {}

variable "enable_cross_zone_load_balancing" {}

variable "enable_connection_draining" {}
variable "connection_draining_timeout" {}

variable "idle_timeout" {}

variable "expose_to_public_internet" {}
