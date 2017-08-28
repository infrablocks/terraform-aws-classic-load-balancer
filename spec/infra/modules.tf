module "base_network" {
  source = "git@github.com:infrablocks/terraform-aws-base-networking.git//src"

  vpc_cidr = "${var.vpc_cidr}"
  region = "${var.region}"
  availability_zones = "${var.availability_zones}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  bastion_ami = "${var.bastion_ami}"
  bastion_ssh_public_key_path = "${var.bastion_ssh_public_key_path}"
  bastion_ssh_allow_cidrs = "${var.bastion_ssh_allow_cidrs}"

  domain_name = "${var.domain_name}"
  public_zone_id = "${var.public_zone_id}"
  private_zone_id = "${var.private_zone_id}"

  infrastructure_events_bucket = "${var.infrastructure_events_bucket}"
}

module "classic_load_balancer" {
  source = "../../../src"

  region = "${var.region}"
  vpc_id = "${module.base_network.vpc_id}"
  subnet_ids = "${split(",", module.base_network.public_subnet_ids)}"

  component = "${var.component}"
  deployment_identifier = "${var.deployment_identifier}"

  listeners = "${var.listeners}"
  access_control = "${var.access_control}"

  egress_cidrs = "${var.egress_cidrs}"

  health_check_target = "${var.health_check_target}"
  health_check_timeout = "${var.health_check_timeout}"
  health_check_interval = "${var.health_check_interval}"
  health_check_unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
  health_check_healthy_threshold = "${var.health_check_healthy_threshold}"

  enable_cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing}"

  enable_connection_draining = "${var.enable_connection_draining}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  idle_timeout = "${var.idle_timeout}"

  expose_to_public_internet = "${var.expose_to_public_internet}"
}
