locals {
    common_tags = {
        Owner       = var.aws_tags_owner
        Environment = var.aws_tags_environment
        Project     = "${var.aws_tags_owner}.${var.aws_tags_project}"
    }
}
