resource "aws_s3_bucket" "encrypted_bucket" {
  bucket = "${var.bucket_name}"

  versioning {
    enabled = true
  }

  tags {
    Name = "bucket-${var.bucket_name}"
  }
}

data "aws_iam_policy_document" "encrypted_bucket_policy" {
  statement {
    sid = "DenyUnEncryptedObjectUploads"

    effect = "Deny"
    actions = ["s3:PutObject"]

    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    condition {
      test = "StringNotEquals"
      values = ["AES256"]
      variable = "s3:x-amz-server-side-encryption"
    }

    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }

  statement {
    sid = "DenyUnEncryptedInflightOperations"

    effect = "Deny"
    actions = ["s3:*"]

    resources = ["arn:aws:s3:::${var.bucket_name}/*"]

    condition {
      test = "Bool"
      values = [false]
      variable = "aws:SecureTransport"
    }

    principals {
      identifiers = ["*"]
      type = "AWS"
    }
  }
}

resource "aws_s3_bucket_policy" "encrypted_bucket" {
  bucket = "${aws_s3_bucket.encrypted_bucket.id}"
  policy = "${data.aws_iam_policy_document.encrypted_bucket_policy.json}"
}
