variable "vpc_id" {
  description = "The ID of the VPC into which to deploy the load balancer."
  type = string
}
variable "subnet_ids" {
  description = "The IDs of the subnets for the ELB."
  type = list(string)
}

variable "domain_name" {
  description = "The domain name of the supplied Route 53 zones."
  type = string
}
variable "public_zone_id" {
  description = "The ID of the public Route 53 zone."
  type = string
}
variable "private_zone_id" {
  description = "The ID of the private Route 53 zone."
  type = string
}

variable "component" {
  description = "The component for which the load balancer is being created."
  type = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
}

variable "listeners" {
  description = "A list of listener configurations for the ELB."
  type = list(object({
    lb_port: number
    lb_protocol: string
    instance_port: number
    instance_protocol: string
    ssl_certificate_id: string
  }))
}
variable "access_control" {
  description = "A list of access control configurations for the security groups."
  type = list(object({
    lb_port: number
    instance_port: number
    allow_cidrs: list(string)
  }))
}

variable "egress_cidrs" {
  description = "The CIDRs that the load balancer is allowed to access."
  type = list(string)
  default = []
}

variable "health_check_target" {
  description = "The target to use for health checks."
  type = string
  default = "TCP:80"
}
variable "health_check_timeout" {
  description = "The time after which a health check is considered failed in seconds."
  type = number
  default = 5
}
variable "health_check_interval" {
  description = "The time between health check attempts in seconds."
  type = number
  default = 30
}
variable "health_check_unhealthy_threshold" {
  description = "The number of failed health checks before an instance is taken out of service."
  type = number
  default = 2
}
variable "health_check_healthy_threshold" {
  description = "The number of successful health checks before an instance is put into service."
  type = number
  default = 10
}

variable "enable_cross_zone_load_balancing" {
  description = "Whether or not to enable cross zone load balancing (\"yes\" or \"no\")."
  type = string
  default = "yes"
}

variable "enable_connection_draining" {
  description = "Whether or not to enable connection draining (\"yes\" or \"no\")."
  type = string
  default = "no"
}
variable "connection_draining_timeout" {
  description = "The time after which connection draining is aborted in seconds."
  type = number
  default = 300
}

variable "idle_timeout" {
  description = "The time after which idle connections are closed."
  type = number
  default = 60
}

variable "include_public_dns_record" {
  description = "Whether or not to create a public DNS entry (\"yes\" or \"no\")."
  type = string
  default = "no"
}
variable "include_private_dns_record" {
  description = "Whether or not to create a private DNS entry (\"yes\" or \"no\")."
  type = string
  default = "yes"
}

variable "expose_to_public_internet" {
  description = "Whether or not to the ELB should be internet facing (\"yes\" or \"no\")."
  type = string
  default = "no"
}
