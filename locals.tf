locals {
  common_tags = {
    Owner   = var.aws_common_tags.Owner
    Project = var.aws_common_tags.Project
  }
  prefix = "${var.aws_common_tags.Owner}-${var.aws_common_tags.Project}"
}