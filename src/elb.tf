resource "aws_elb" "load_balancer" {
  subnets = ["${var.subnet_ids}"]
  listener = "${var.listeners}"
}
