locals {
  common_tags = {
    Owner       = var.aws_tags_owner
    Environment = var.aws_tags_environment
    Project     = "${var.aws_tags_owner}.${var.aws_tags_project}"
  }

  s3_bucket_name = "js-learninglab-terraform-${random_integer.s3.result}"
}


resource "random_integer" "s3" {
  min = 10000
  max = 99999
}