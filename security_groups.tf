data "aws_vpc" "base_network" {
  id = var.vpc_id
}

resource "aws_security_group" "load_balancer" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  description = "ELB for component: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "elb_egress" {
  type = "egress"

  from_port = 1
  to_port = 65535
  protocol = "tcp"
  cidr_blocks = coalescelist(var.egress_cidrs, list(data.aws_vpc.base_network.cidr_block))

  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group_rule" "elb_ingress" {
  type = "ingress"
  count = length(var.access_control)

  from_port = var.access_control[count.index].lb_port
  to_port = var.access_control[count.index].lb_port
  protocol = "tcp"
  cidr_blocks = var.access_control[count.index].allow_cidrs

  security_group_id = aws_security_group.load_balancer.id
}

resource "aws_security_group" "open_to_load_balancer" {
  name = "open-to-elb-${var.component}-${var.deployment_identifier}"
  description = "Open to ELB for component: ${var.component}, deployment: ${var.deployment_identifier}"
  vpc_id = var.vpc_id
}

resource "aws_security_group_rule" "open_to_elb_ingress" {
  type = "ingress"
  count = length(var.access_control)

  from_port = var.access_control[count.index].instance_port
  to_port = var.access_control[count.index].instance_port
  protocol = "tcp"
  source_security_group_id = aws_security_group.load_balancer.id

  security_group_id = aws_security_group.open_to_load_balancer.id
}
