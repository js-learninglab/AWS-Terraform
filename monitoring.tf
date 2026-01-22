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
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            for index, instance in aws_instance.a_web_servers :
            ["MyApp/Metrics", "404ErrorCount", { "stat" : "Sum", "period" : 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Count 404 errors"
          period  = 300
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 24
        height = 6
        properties = {
          metrics = [
            for index, instance in aws_instance.a_web_servers :
            ["MyApp/Metrics", "500ErrorCount", { "stat" : "Sum", "period" : 300 }]
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.aws_region
          title   = "Count 500 errors"
          period  = 300
        }
      }
    ]
  })

}

### create cloudwatch log metric filter
resource "aws_cloudwatch_log_metric_filter" "count_404_errors" {
  name           = "count-404-errors"
  log_group_name = aws_cloudwatch_log_group.aws_cloudwatch_access_log_group.name
  pattern        = "[host, ident, authuser, date, request, status=404, bytes, referrer, useragent]"

  metric_transformation {
    name      = "404ErrorCount"
    namespace = "MyApp/Metrics"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_metric_filter" "count_500_errors" {
  name           = "count-500-errors"
  log_group_name = aws_cloudwatch_log_group.aws_cloudwatch_error_log_group.name
  pattern        = "[host, ident, authuser, date, request, status=500, bytes, referrer, useragent]"

  metric_transformation {
    name      = "500ErrorCount"
    namespace = "MyApp/Metrics"
    value     = "1"
  }
}

### create cloudwatch alarm for 404 and 500 errors
resource "aws_cloudwatch_metric_alarm" "alarm_404_errors" {
  alarm_name                = "${local.prefix}-404-Errors-Alarm-${var.environment}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.count_404_errors.metric_transformation[0].name
  namespace                 = aws_cloudwatch_log_metric_filter.count_404_errors.metric_transformation[0].namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "5"
  alarm_description         = "Alarm for high number of 404 errors"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []
  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-404-Errors-Alarm-${var.environment}"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "alarm_500_errors" {
  alarm_name                = "${local.prefix}-500-Errors-Alarm-${var.environment}"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "1"
  metric_name               = aws_cloudwatch_log_metric_filter.count_500_errors.metric_transformation[0].name
  namespace                 = aws_cloudwatch_log_metric_filter.count_500_errors.metric_transformation[0].namespace
  period                    = "300"
  statistic                 = "Sum"
  threshold                 = "5"
  alarm_description         = "Alarm for high number of 500 errors"
  alarm_actions             = [aws_sns_topic.cpu_utilization_alerts.arn]
  insufficient_data_actions = []
  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-500-Errors-Alarm-${var.environment}"
    }
  )
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

# create virtual machine for prometheus and grafana monitoring
resource "aws_instance" "a_prom_graf_server" {
  ami                         = data.aws_ami.linux.id
  instance_type               = "t2.small"                               #this instance might require more resources hence not t2.micro
  subnet_id                   = module.aws_vpc_backend.public_subnets[0] #placing in first subnet since it is just one instance
  key_name                    = aws_key_pair.a_ec2_ssh_key.key_name
  vpc_security_group_ids      = [aws_security_group.a_prom_graf_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.a_allow_prom_graf_scrape_profile.name

  # need to add more disk because logs say "no space left on device"
  root_block_device {
    volume_size = 20 # 20GB instead of default 8GB
    volume_type = "gp3"
  }

  user_data = <<-EOF
    ${file("./Templates/installpython.tpl")}
    ${file("./Templates/installprometheus.tpl")}
    ${file("./Templates/installgrafana.tpl")}
    ${file("./Templates/installcloudwatchexporter.tpl")}

  EOF

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-a-prom-graf-server" })
}

