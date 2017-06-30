output "registry_id" {
  value = "${aws_ecr_repository.repository.registry_id}"
}
output "repository_url" {
  value = "${aws_ecr_repository.repository.repository_url}"
}
