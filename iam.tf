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



### iam role for prom_graf monitoring server to scrape data from web servers ###
resource "aws_iam_role" "a_allow_prom_graf_scrape" {
  name = "a_allow_prom_graf_scrape"

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

### create iam instance profile for prom_graf monitoring server
resource "aws_iam_instance_profile" "a_allow_prom_graf_scrape_profile" {
  name = "a_allow_prom_graf_scrape_profile"
  role = aws_iam_role.a_allow_prom_graf_scrape.name

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-a_allow_prom_graf_scrape_profile" })
}

### create iam role policy for prom_graf monitoring server
resource "aws_iam_role_policy" "a_allow_prom_graf_scrape_policy" {
  name = "a_allow_prom_graf_scrape_policy"
  role = aws_iam_role.a_allow_prom_graf_scrape.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "tag:GetResources",
          "rds:DescribeDBInstances"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

### create iam role policy web servers to access secrets manager ###
resource "aws_iam_role_policy" "a_allow_web_servers_secrets_manager_policy" {
  name = "a_allow_web_servers_secrets_manager_policy"
  role = aws_iam_role.a_allow_web_servers_s3.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Effect   = "Allow"
        Resource = aws_secretsmanager_secret.a_rds_password_secret.arn
      }
    ]
  })
}