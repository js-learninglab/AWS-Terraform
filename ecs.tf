### Configure ECS Cluster
resource "aws_ecs_cluster" "main" {
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


