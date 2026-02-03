/*
# create s3 bucket >> this is removed because i have introduced s3 bucket module in main.tf
resource "aws_s3_bucket" "a_s3_bucket" {
  bucket        = local.s3_bucket_name
  force_destroy = true
  tags          = merge(local.common_tags, { Name = lower("${local.naming_prefix}-s3-bucket") })
}
*/

# create s3 bucket policy
resource "aws_s3_bucket_policy" "a_s3_bucket_policy" {
  bucket = module.aws_s3.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          "AWS" = "${data.aws_elb_service_account.root.arn}"
        }
        Resource = [
          "arn:aws:s3:::${local.s3_bucket_name}/a-web-lb-logs/*",
          "arn:aws:s3:::${local.s3_bucket_name}/asg-web-lb-logs/*",
          "arn:aws:s3:::${local.s3_bucket_name}/ecs-web-lb-logs/*"
        ]
      },
      {
        Action = "s3:PutObject"
        Effect = "Allow"
        Principal = {
          "Service" = "delivery.logs.amazonaws.com"
        }
        Resource = [
          "arn:aws:s3:::${local.s3_bucket_name}/a-web-lb-logs/*",
          "arn:aws:s3:::${local.s3_bucket_name}/asg-web-lb-logs/*"
        ]
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Action = "s3:GetBucketAcl"
        Effect = "Allow"
        Principal = {
          "Service" = "delivery.logs.amazonaws.com"
        }
        Resource = "arn:aws:s3:::${local.s3_bucket_name}"
      }
    ]
  })
}

# create s3 object
resource "aws_s3_object" "a_s3_website_content" {
  for_each = local.website_content
  bucket   = module.aws_s3.s3_bucket_id
  key      = each.value
  source   = "${path.root}/${each.value}"

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-s3-website-content-${each.key}" })
}
# REMOVING THIS BECAUSE OF FOR_EACH IN aws_s3_object a_s3_website_content
