# aws lb service account
data "aws_elb_service_account" "root" {}

# create aws loadbalancer
resource "aws_lb" "a_web_lb" {
  name               = "a-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.a_web_lb_sg.id]
  subnets            = aws_subnet.a_web_subnets[*].id
  depends_on         = [aws_s3_bucket_policy.a_s3_bucket_policy]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.a_s3_bucket.bucket
    prefix  = "a-web-lb-logs"
    enabled = true
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-lb" })
}

# create aws lb target group
resource "aws_lb_target_group" "a_web_lb_tg" {
  name     = "a-web-lb-tg"
  port     = var.aws_tcp_80
  protocol = "HTTP" #doesn't like variable here and also case sensitive
  vpc_id   = aws_vpc.a_vpc.id

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-lb-tg" })
}

# create aws lb listener
resource "aws_lb_listener" "a_web_lb_listener" {
  load_balancer_arn = aws_lb.a_web_lb.arn
  port              = var.aws_tcp_80
  protocol          = "HTTP" #doesn't like variable here and also case sensitive

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.a_web_lb_tg.arn
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-lb-listener" })
}

# create aws lb target group attachment for web servers
resource "aws_lb_target_group_attachment" "a_web_lb_tg_attach" {
  count = var.aws_web_server_count #reusing the web server count instead
  target_group_arn = aws_lb_target_group.a_web_lb_tg.arn
  target_id        = aws_instance.a_web_servers[count.index].id
  port             = var.aws_tcp_80
}

# create aws lb target group attachment for web server2 >> REMOVED BECAUSE OF COUNT IN aws_lb_target_group_attachment a_web_lb_tg_attach 