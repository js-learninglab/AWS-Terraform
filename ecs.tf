### Configure ECS Cluster
resource "aws_ecs_cluster" "a_ecs_cluster" {
  name = "${local.naming_prefix}-${var.environment}-ecs-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecs-cluster" })
}

### create task definition for ecs
resource "aws_ecs_task_definition" "a_ecs_task_definition" {
  family                   = "${local.naming_prefix}-${var.environment}-ecs-web-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.a_ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.a_ecs_task_role.arn

  container_definitions = jsonencode(
    [
      {
        name      = "nginx-container"
        image     = var.ecs_container_image
        essential = true
        portMappings = [
          {
            containerPort = var.aws_tcp_80
            protocol      = "tcp"
        }]

        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.aws_ecs_cluster_log_group.name
            "awslogs-region"        = var.aws_region
            "awslogs-stream-prefix" = "nginx-container"
          }
        }
      }
  ])
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-ecs-task-def" })
}


### create ecs service
resource "aws_ecs_service" "a_ecs_service" {
  name            = "${local.naming_prefix}-${var.environment}-ecs-service"
  cluster         = aws_ecs_cluster.a_ecs_cluster.id
  task_definition = aws_ecs_task_definition.a_ecs_task_definition.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = module.aws_vpc.public_subnets
    security_groups  = [aws_security_group.ecs_web_sg.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_web_lb_tg.arn
    container_name   = "nginx-container"
    container_port   = var.aws_tcp_80
  }

  depends_on = [aws_lb_listener.ecs_web_lb_listener]
}

