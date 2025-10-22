locals {
  common_tags = {
    Owner   = var.aws_common_tags.Owner
    Project = var.aws_common_tags.Project
  }
  prefix = "${var.aws_common_tags.Owner}-${var.aws_common_tags.Project}"

  s3_bucket_name = "${local.prefix}-S3bucket-${random_integer.random_number.result}"
}

resource "random_integer" "random_number" {
  min = 10000
  max = 99999
}