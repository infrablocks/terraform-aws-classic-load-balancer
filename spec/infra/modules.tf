module "encrypted_bucket" {
  source = "../../../src"

  region = "${var.region}"
  bucket_name = "${var.bucket_name}"
}
