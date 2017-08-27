output "vpc_id" {
  value = "${module.base_network.vpc_id}"
}

output "subnet_ids" {
  value = "${module.base_network.public_subnet_ids}"
}

output "name" {
  value = "${module.classic_load_balancer.name}"
}