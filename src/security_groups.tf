resource "aws_security_group" "elb" {
  name = "elb-${var.component}-${var.deployment_identifier}"
  vpc_id = "${var.vpc_id}"
}