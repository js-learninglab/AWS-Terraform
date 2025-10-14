# aws_web_lb
resource "aws_lb" "web_lb" {
  name               = "aws-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.nginx_sg.id]
  subnets            = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]

  enable_deletion_protection = false

  access_logs {
    bucket  = aws_s3_bucket.aws_storage.id
    prefix  = "web-lb-logs"
    enabled = true
  }

  tags = merge(local.common_tags, { Name = "web-lb" })
}
# aws_lb_target_group
resource "aws_lb_target_group" "web_lb_tg" {
  name     = "aws-web-lb-tg"
  port     = var.aws_web_http_port
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  tags = merge(local.common_tags, { Name = "web-tg" })
}

# aws_lb_listener
resource "aws_lb_listener" "web_lb_listener" {
  load_balancer_arn = aws_lb.web_lb.arn
  port              = var.aws_web_http_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_lb_tg.arn
  }

  tags = merge(local.common_tags, { Name = "web-listener" })
}

# aws_lb_target_group_attachment
resource "aws_lb_target_group_attachment" "web_lb_tg_attachment" {
  count            = length(aws_instance.web_server[*].id)
  target_group_arn = aws_lb_target_group.web_lb_tg.arn
  target_id        = aws_instance.web_server[count.index].id
  port             = var.aws_web_http_port
}

/*
resource "aws_lb_target_group_attachment" "web_lb_tg_attachment2" {
  target_group_arn = aws_lb_target_group.web_lb_tg.arn
  target_id        = aws_instance.web_server2.id
  port             = var.aws_web_http_port
}
*/