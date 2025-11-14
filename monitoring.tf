### Create aws cloudwatch resource 
### Learning to create using for each in single resource for multiple instances
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  for_each = {
    for pair in setproduct(
      ["cpu", "disk_read", "disk_write"], #these are the metrics
      keys({ for index, instance in aws_instance.a_web_servers : index + 1 => instance })) : "${pair[0]}-${pair[1]}" => {
      metric   = pair[0]
      instance = pair[1]
    }
  }

  alarm_name          = "${local.prefix}-${each.value.metric}-server-${each.value.instance}-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = each.value.metric == "cpu" ? "CPUUtilization" : each.value.metric == "disk_read" ? "DiskReadBytes" : "DiskWriteBytes"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = each.value.metric == "cpu" ? "80" : "1000000000" # 80% for CPU, 1GB for disk

  dimensions = {
    InstanceId = aws_instance.a_web_servers[each.value.instance - 1].id
  }

  alarm_description         = "This metric monitors ${each.value.metric} for server ${each.value.instance}"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-${each.value.metric}-server-${each.value.instance}-${var.environment}"
    }
  )
}

### create aws cloudwatch resource using count
### learning to create separate resources for easier understanding
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_host" {
  alarm_name          = "${local.prefix}-Unhealthy-Host-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = "60"
  statistic           = "Average"
  threshold           = "0"

  dimensions = {
    TargetGroup  = aws_lb_target_group.a_web_lb_tg.arn_suffix
    LoadBalancer = aws_lb.a_web_lb.arn_suffix
  }

  alarm_description         = "Alert for any unhealthy target"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-Unhealthy-Host-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "slow_response_time" {
  alarm_name          = "${local.prefix}-Slow-Response-Time-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "ResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Average"
  threshold           = "2"

  dimensions = {
    LoadBalancer = aws_lb.a_web_lb.arn_suffix
  }

  alarm_description         = "This metric monitors response time"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-Slow-Response-Time-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "high_5xx_errors" {
  alarm_name          = "${local.prefix}-High-5XX-Errors-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "HTTPCode_Target_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = "120"
  statistic           = "Sum"
  threshold           = "10"

  dimensions = {
    LoadBalancer = aws_lb.a_web_lb.arn_suffix
  }

  alarm_description         = "This metric monitors Web ALB 5XX errors"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-High-5XX-Errors-${var.environment}"
    }
  )
}


### Create aws sns for notification
resource "aws_sns_topic" "cpu_utilization_alerts" {
  name = "${local.prefix}-cpu-utilization-alerts-${var.environment}"

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-cpu-utilization-alerts-${var.environment}"
    }
  )
}


### create aws sns subscription
resource "aws_sns_topic_subscription" "cpu_utilization_alerts_subscription" {
  topic_arn = aws_sns_topic.cpu_utilization_alerts.arn
  protocol  = "email"
  endpoint  = "js.learninglab@hotmail.com"
}


### Create cloudwatch metric alarm dashboard
resource "aws_cloudwatch_dashboard" "js_learninglab_dashboard" {
  dashboard_name = "${local.prefix}-dashboard-${var.environment}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          metrics = [
            for index, instance in aws_instance.a_web_servers :
            ["AWS/EC2", "CPUUtilization", "InstanceId", instance.id, { "stat" : "Average", "period" : 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "EC2 Instance CPU Utilization"
          period  = 300
        }
      }
    ]
  })

}


### create log group
resource "aws_cloudwatch_log_group" "aws_cloudwatch_access_log_group" {
  name              = "nginx_access_logs-${var.environment}"
  retention_in_days = 7
  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-nginx-access-log-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_log_group" "aws_cloudwatch_error_log_group" {
  name              = "nginx_error_logs-${var.environment}"
  retention_in_days = 7

  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-nginx-error-log-${var.environment}"
    }
  )
}