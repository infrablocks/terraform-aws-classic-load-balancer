resource "aws_ecr_repository" "repository" {
  name = "${var.repository_name}"
}
