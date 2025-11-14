### MOVING IAM ROLE TO SEPARATE FILE iam.tf ###

### iam role for web servers to access s3 bucket ###
# create iam role
resource "aws_iam_role" "a_allow_web_servers_s3" {
  name = "a_allow_web_servers_s3"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# create iam instance profile
resource "aws_iam_instance_profile" "a_allow_web_servers_s3_profile" {
  name = "a_allow_web_servers_s3_profile"
  role = aws_iam_role.a_allow_web_servers_s3.name

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-a_allow_web_servers_s3_profile" })
}

# create iam role policy
resource "aws_iam_role_policy" "a_allow_web_servers_s3_policy" {
  name = "a_allow_web_servers_s3_policy"
  role = aws_iam_role.a_allow_web_servers_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${local.s3_bucket_name}",
          "arn:aws:s3:::${local.s3_bucket_name}/*"
        ]
      }
    ]
  })
}

### iam role for monitoring (cloudwatch agent) | reuse from iam role for web servers instead
### create iam policy for cloudwatch agent
resource "aws_iam_role_policy" "a_allow_cloudwatch_agent_policy" {
  name = "a_allow_cloudwatch_agent_policy"
  role = aws_iam_role.a_allow_web_servers_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}
