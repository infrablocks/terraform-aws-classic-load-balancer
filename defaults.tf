locals {
  # default for cases when `null` value provided, meaning "use default"
  access_control                   = var.access_control == null ? [] : var.access_control
  egress_cidrs                     = var.egress_cidrs == null ? [] : var.egress_cidrs
  health_check_target              = var.health_check_target == null ? "TCP:80" : var.health_check_target
  health_check_timeout             = var.health_check_timeout == null ? 5 : var.health_check_timeout
  health_check_interval            = var.health_check_interval == null ? 30 : var.health_check_interval
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold == null ? 2 : var.health_check_unhealthy_threshold
  health_check_healthy_threshold   = var.health_check_healthy_threshold == null ? 10 : var.health_check_healthy_threshold
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing == null ? "yes" : var.enable_cross_zone_load_balancing
  enable_connection_draining       = var.enable_connection_draining == null ? "no" : var.enable_connection_draining
  connection_draining_timeout      = var.connection_draining_timeout == null ? 300 : var.connection_draining_timeout
  idle_timeout                     = var.idle_timeout == null ? 60 : var.idle_timeout
  include_public_dns_record        = var.include_public_dns_record == null ? "no" : var.include_public_dns_record
  include_private_dns_record       = var.include_private_dns_record == null ? "yes" : var.include_private_dns_record
  expose_to_public_internet        = var.expose_to_public_internet == null ? "no" : var.expose_to_public_internet
}
