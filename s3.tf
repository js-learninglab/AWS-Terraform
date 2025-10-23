# create s3 bucket
resource "aws_s3_bucket" "a_s3_bucket" {
  bucket = local.s3_bucket_name
  force_destroy = true
  tags = merge(local.common_tags, { Name = lower("${local.prefix}-s3-bucket") })
}

# create s3 bucket policy
resource "aws_s3_bucket_policy" "a_s3_bucket_policy" {
  bucket = aws_s3_bucket.a_s3_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "s3:PutObject"
        Effect    = "Allow"
        Principal = {
            "AWS" = "${data.aws_elb_service_account.root.arn}"
        }
        Resource  = "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
        },
        {
        Action    = "s3:PutObject"
        Effect    = "Allow"
        Principal = {
            "Service" = "delivery.logs.amazonaws.com"
        }
        Resource  = "arn:aws:s3:::${local.s3_bucket_name}/alb-logs/*"
        condition = {
            StringEquals = {
                "s3:x-amz-acl" = "bucket-owner-full-control"
            }
        }        
      },
      {
        Action    = "s3:GetBucketAcl"
        Effect    = "Allow"
        Principal = {
            "Service" = "delivery.logs.amazonaws.com"
        }
        Resource  = "arn:aws:s3:::${local.s3_bucket_name}"
      }
    ]
  })
}

# create s3 object
resource "aws_s3_object" "a_s3_website" {
  bucket = aws_s3_bucket.a_s3_bucket.bucket
  key    = "/website/index.html"
  source = "./Website/Index.html"

  tags = merge(local.common_tags, { Name = "${local.prefix}-s3-website-object" })
}

resource "aws_s3_object" "a_s3_image" {
  bucket = aws_s3_bucket.a_s3_bucket.bucket
  key    = "/website/JS learningLab.png"
  source = "./Website/JS learningLab.png"

  tags = merge(local.common_tags, { Name = "${local.prefix}-s3-website-image" })
}