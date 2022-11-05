resource "aws_elb" "load_balancer" {
  subnets = var.subnet_ids
  security_groups = [
    aws_security_group.load_balancer.id
  ]

  internal = local.expose_to_public_internet == "yes" ? false : true

  cross_zone_load_balancing = local.enable_cross_zone_load_balancing == "yes" ? true : false

  connection_draining = local.enable_connection_draining == "yes" ? true : false
  connection_draining_timeout = local.connection_draining_timeout

  idle_timeout = local.idle_timeout

  dynamic "listener" {
    for_each = var.listeners
    content {
      instance_port = listener.value.instance_port
      instance_protocol = listener.value.instance_protocol
      lb_port = listener.value.lb_port
      lb_protocol = listener.value.lb_protocol
      ssl_certificate_id = listener.value.ssl_certificate_id
    }
  }

  health_check {
    target = local.health_check_target
    timeout = local.health_check_timeout
    interval = local.health_check_interval
    unhealthy_threshold = local.health_check_unhealthy_threshold
    healthy_threshold = local.health_check_healthy_threshold
  }

  tags = {
    Name = "elb-${var.component}-${var.deployment_identifier}"
    Component = var.component
    DeploymentIdentifier = var.deployment_identifier
  }
}
