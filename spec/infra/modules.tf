module "ecr_repository" {
  source = "../../../src"

  region = "${var.region}"
  repository_name = "${var.repository_name}"
}
