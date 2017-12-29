variable "region" {
  description = "The region into which to deploy the load balancer."
}
variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the load balancer."
}
variable "subnet_ids" {
  description = "The IDs of the subnets for the ELB."
  type = "list"
}

variable "domain_name" {
  description = "The domain name of the supplied Route 53 zones."
}
variable "public_zone_id" {
  description = "The ID of the public Route 53 zone."
}
variable "private_zone_id" {
  description = "The ID of the private Route 53 zone."
}

variable "component" {
  description = "The component for which the load balancer is being created."
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "listeners" {
  description = "A list of listener configurations for the ELB."
  type = "list"
}
variable "access_control" {
  description = "A list of access control configurations for the security groups."
  type = "list"
}

variable "egress_cidrs" {
  description = "The CIDRs that the load balancer is allowed to access."
  type = "list"
  default = []
}

variable "health_check_target" {
  description = "The target to use for health checks."
  default = "TCP:80"
}
variable "health_check_timeout" {
  description = "The time after which a health check is considered failed in seconds."
  default = 5
}
variable "health_check_interval" {
  description = "The time between health check attempts in seconds."
  default = 30
}
variable "health_check_unhealthy_threshold" {
  description = "The number of failed health checks before an instance is taken out of service."
  default = 2
}
variable "health_check_healthy_threshold" {
  description = "The number of successful health checks before an instance is put into service."
  default = 10
}

variable "enable_cross_zone_load_balancing" {
  description = "Whether or not to enable cross zone load balancing (\"yes\" or \"no\")."
  default = "yes"
}

variable "enable_connection_draining" {
  description = "Whether or not to enable connection draining (\"yes\" or \"no\")."
  default = "no"
}
variable "connection_draining_timeout" {
  description = "The time after which connection draining is aborted in seconds."
  default = 300
}

variable "idle_timeout" {
  description = "The time after which idle connections are closed."
  default = 60
}

variable "include_public_dns_record" {
  description = "Whether or not to create a public DNS entry (\"yes\" or \"no\")."
  default = "no"
}
variable "include_private_dns_record" {
  description = "Whether or not to create a private DNS entry (\"yes\" or \"no\")."
  default = "yes"
}

variable "expose_to_public_internet" {
  description = "Whether or not to the ELB should be internet facing (\"yes\" or \"no\")."
  default = "no"
}
