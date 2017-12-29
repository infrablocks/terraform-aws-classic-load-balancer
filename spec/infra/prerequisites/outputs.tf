output "vpc_id" {
  value = "${module.base_network.vpc_id}"
}

output "vpc_cidr" {
  value = "${module.base_network.vpc_cidr}"
}

output "subnet_ids" {
  value = "${module.base_network.public_subnet_ids}"
}
