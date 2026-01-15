locals {
  common_tags = {
    Owner   = var.aws_common_tags.Owner
    Project = var.aws_common_tags.Project
  }
  prefix        = "${var.aws_common_tags.Owner}-${var.aws_common_tags.Project}"
  naming_prefix = var.aws_naming_prefix

  s3_bucket_name = "${lower(local.naming_prefix)}-s3-${random_integer.random_number.result}"

  autoscaling_prefix = "${local.naming_prefix}-asg"

  website_content = {
    website = "website/index.html"
    image   = "website/JS_learningLab.png"
  }
}

resource "random_integer" "random_number" {
  min = 10000
  max = 99999
}

resource "random_password" "rds_password" {
  length           = 16
  special          = true
  override_special = "_%!$#"
}