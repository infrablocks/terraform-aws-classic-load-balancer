resource "aws_elb" "load_balancer" {
  subnets = ["${var.subnet_ids}"]
  security_groups = [
    "${aws_security_group.load_balancer.id}"
  ]

  internal = "${var.expose_to_public_internet == "yes" ? false : true}"

  cross_zone_load_balancing = "${var.enable_cross_zone_load_balancing == "yes" ? true : false}"

  connection_draining = "${var.enable_connection_draining == "yes" ? true : false}"
  connection_draining_timeout = "${var.connection_draining_timeout}"

  idle_timeout = "${var.idle_timeout}"

  listener = ["${var.listeners}"]

  health_check {
    target = "${var.health_check_target}"
    timeout = "${var.health_check_timeout}"
    interval = "${var.health_check_interval}"
    unhealthy_threshold = "${var.health_check_unhealthy_threshold}"
    healthy_threshold = "${var.health_check_healthy_threshold}"
  }

  tags {
    Name = "elb-${var.component}-${var.deployment_identifier}"
    Component = "${var.component}"
    DeploymentIdentifier = "${var.deployment_identifier}"
  }
}
