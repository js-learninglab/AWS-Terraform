# create aws loadbalancer
resource "aws_lb" "a_web_lb" {
  name               = "a-web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.a_web_lb_sg.id]
  subnets            = [aws_subnet.a_web_subnet1.id, aws_subnet.a_web_subnet2.id]

  enable_deletion_protection = false

  tags = merge(local.common_tags, { Name = "${local.prefix}-lb" })
}

# create aws lb target group
resource "aws_lb_target_group" "a_web_lb_tg" {
  name     = "a-web-lb-tg"
  port     = var.aws_tcp_80
  protocol = "HTTP"
  vpc_id   = aws_vpc.a_vpc.id

  tags = merge(local.common_tags, { Name = "${local.prefix}-lb-tg" })
}

# create aws lb listener
resource "aws_lb_listener" "a_web_lb_listener" {
  load_balancer_arn = aws_lb.a_web_lb.arn
  port              = var.aws_tcp_80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.a_web_lb_tg.arn
  }

  tags = merge(local.common_tags, { Name = "${local.prefix}-lb-listener" })
}

# create aws lb target group attachment
resource "aws_lb_target_group_attachment" "a_web_lb_tg_attach1" {
    target_group_arn = aws_lb_target_group.a_web_lb_tg.arn
    target_id        = aws_instance.a_web_server1.id
    port             = var.aws_tcp_80
}

resource "aws_lb_target_group_attachment" "a_web_lb_tg_attach2" {
    target_group_arn = aws_lb_target_group.a_web_lb_tg.arn
    target_id        = aws_instance.a_web_server2.id
    port             = var.aws_tcp_80
}