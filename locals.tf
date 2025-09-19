locals {
  common_tags = {
    Owner       = var.aws_tags_owner
    Environment = var.aws_tags_environment
    Project     = "${var.aws_tags_owner}.${var.aws_tags_project}"
  }
}


resource "random_integer" "s3" {
  min = 10000
  max = 99999
}