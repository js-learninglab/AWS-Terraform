### create launch template blueprint for my instances
# migrate resource from aws_instance to aws_launch_template
resource "aws_launch_template" "asg_aws_launch_template" {
  name_prefix   = "${local.naming_prefix}-asg-"
  image_id      = data.aws_ami.linux.id # referring back to the same data source for AMI
  instance_type = var.aws_instance_type
  key_name      = aws_key_pair.a_ec2_ssh_key.key_name
  #vpc_security_group_ids = [aws_security_group.a_web_sg.id] # commenting this because using network_interfaces instead
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.a_web_sg.id]
    delete_on_termination       = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.a_allow_web_servers_s3_profile.name
  }
  user_data = base64encode(<<-EOF
    ${file("./Templates/installpython.tpl")}
    ${file("./Templates/installpostgres.tpl")}
    ${templatefile("./Templates/startupscript2.tpl", {
    s3_bucket_name = module.aws_s3.s3_bucket_id
})}
  EOF
)
lifecycle {
  create_before_destroy = true
}
}

### create autoscaling group for managing my instances
resource "aws_autoscaling_group" "aws_autoscaling_group" {
  desired_capacity          = var.asg_aws_server_count_desired
  max_size                  = var.asg_aws_server_count_max
  min_size                  = var.asg_aws_server_count_min
  target_group_arns         = [aws_lb_target_group.asg_web_lb_tg.arn]
  health_check_type         = "ELB"
  health_check_grace_period = 300

  launch_template {
    id      = aws_launch_template.asg_aws_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = module.aws_vpc.public_subnets # replace with valid subnet IDs

  tag {
    key                 = "Name"
    value               = "${local.autoscaling_prefix}-${var.environment}"
    propagate_at_launch = true
  }

  tag {
    key                 = "Owner"
    value               = local.common_tags.Owner
    propagate_at_launch = true
  }

  tag {
    key                 = "Project"
    value               = local.common_tags.Project
    propagate_at_launch = true
  }

  tag {
    key                 = "environment"
    value               = var.environment
    propagate_at_launch = true
  }
}

### create policies for scaling in and out
resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "asg-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.aws_autoscaling_group.name
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "asg-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.aws_autoscaling_group.name
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
}

### create cloudwatch alarms to trigger scaling policies
resource "aws_cloudwatch_metric_alarm" "asg_cpu_high_alarm" {
  alarm_name          = "asg-cpu-high-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 70

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_autoscaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.asg_scale_out_policy.arn]
}

resource "aws_cloudwatch_metric_alarm" "asg_cpu_low_alarm" {
  alarm_name          = "asg-cpu-low-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.aws_autoscaling_group.name
  }

  alarm_actions = [aws_autoscaling_policy.asg_scale_in_policy.arn]
}