### Create aws cloudwatch resource
resource "aws_cloudwatch_metric_alarm" "high_cpu_utilization" {
  alarm_name          = "${local.prefix}-High-CPU-Utilization-${var.environment}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    InstanceId = aws_instance.web_server.*.id[0]
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  insufficient_data_actions = []
  
  tags = merge(
    local.common_tags,
    {
      Environment = var.environment
      Name        = "${local.prefix}-High-CPU-Utilization-${var.environment}"
    }
  )
}