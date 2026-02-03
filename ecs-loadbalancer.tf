### separate loadbalancer file for ECS setup ###

# create ecs aws lb 
resource "aws_lb" "ecs_web_lb" {
  name               = "ecs-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ecs_web_lb_sg.id]
  subnets            = module.aws_vpc.public_subnets
  depends_on         = [aws_s3_bucket_policy.a_s3_bucket_policy]

  enable_deletion_protection = false

  access_logs {
    bucket  = module.aws_s3.s3_bucket_id
    prefix  = "ecs-web-lb-logs"
    enabled = true
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecs-lb" })
}

# create ecs aws lb target group
resource "aws_lb_target_group" "ecs_web_lb_tg" {
  name        = "ecs-web-lb-tg"
  port        = var.aws_tcp_80
  protocol    = "HTTP" #doesn't like variable here and also case sensitive
  vpc_id      = module.aws_vpc.vpc_id
  target_type = "ip"

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecs-lb-tg" })
}

# create ecs aws lb listener
resource "aws_lb_listener" "ecs_web_lb_listener" {
  load_balancer_arn = aws_lb.ecs_web_lb.arn
  port              = var.aws_tcp_80
  protocol          = "HTTP" #doesn't like variable here and also case sensitive

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_web_lb_tg.arn
  }


  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecs-lb-listener" })
}   