### create launch template blueprint for my instances
# migrate resource from aws_instance to aws_launch_template
resource "aws_launch_template" "asg_aws_launch_template" {
  name_prefix   = "${local.naming_prefix}-asg-"
  image_id      = data.aws_ami.linux.id  # referring back to the same data source for AMI
  instance_type = var.aws_instance_type

  lifecycle {
    create_before_destroy = true
  }
}

### create autoscaling group for managing my instances
resource "aws_autoscaling_group" "aws_autoscaling_group" {
  desired_capacity     = 2
  max_size             = 4
  min_size             = 1
  launch_template {
    id      = aws_launch_template.aws_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier = [ "subnet-0123456789abcdef0", "subnet-0fedcba9876543210" ]  # replace with valid subnet IDs

  tag  {
    
      key                 = "Name"
      value               = "${local.autoscaling_prefix}-${var.environment}"
      propagate_at_launch = true
    }

    tag= []
    for key, value in local.common_tags : {
      key                 = key
      value               = value
      propagate_at_launch = true
    }
  
}

### create policies for scaling in and out


### create cloudwatch alarms to trigger scaling policies