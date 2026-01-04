/*
########################################################################
##################LOAD BALANCER FOR AUTO SCALING GROUP##################
########################################################################
*/

# create aws loadbalancer for auto scaling group
resource "aws_lb" "asg_web_lb" {
  name               = "asg-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.a_web_lb_sg.id] # reusing the same security group as web lb
  subnets            = module.aws_vpc.public_subnets
  depends_on         = [aws_s3_bucket_policy.a_s3_bucket_policy]

  enable_deletion_protection = false

  access_logs {
    bucket  = module.aws_s3.s3_bucket_id
    prefix  = "asg-web-lb-logs"
    enabled = true
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-asg-lb" })
}

# create aws loadbalancer target group for auto scaling group
resource "aws_lb_target_group" "asg_web_lb_tg" {
  name     = "asg-web-lb-tg"
  port     = var.aws_tcp_80
  protocol = "HTTP" # doesn't like variable here and also case sensitive
  vpc_id   = module.aws_vpc.vpc_id

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-asg-lb-tg" })
}

# create aws loadbalancer listener for auto scaling group
resource "aws_lb_listener" "asg_web_lb_listener" {
  load_balancer_arn = aws_lb.asg_web_lb.arn
  port              = var.aws_tcp_80
  protocol          = "HTTP" # doesn't like variable here and also case sensitive

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg_web_lb_tg.arn
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-asg-lb-listener" })
}