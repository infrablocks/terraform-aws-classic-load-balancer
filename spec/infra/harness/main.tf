data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "classic_load_balancer" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "./../../../../../../../"

  vpc_id = data.terraform_remote_state.prerequisites.outputs.vpc_id
  subnet_ids = data.terraform_remote_state.prerequisites.outputs.subnet_ids

  domain_name = var.domain_name
  public_zone_id = var.public_zone_id
  private_zone_id = var.private_zone_id

  component = var.component
  deployment_identifier = var.deployment_identifier

  listeners = var.listeners
  access_control = var.access_control

  egress_cidrs = var.egress_cidrs

  health_check_target = var.health_check_target
  health_check_timeout = var.health_check_timeout
  health_check_interval = var.health_check_interval
  health_check_unhealthy_threshold = var.health_check_unhealthy_threshold
  health_check_healthy_threshold = var.health_check_healthy_threshold

  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing

  enable_connection_draining = var.enable_connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  idle_timeout = var.idle_timeout

  include_public_dns_record = var.include_public_dns_record
  include_private_dns_record = var.include_private_dns_record

  expose_to_public_internet = var.expose_to_public_internet
}
