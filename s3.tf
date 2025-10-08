# aws_s3_bucket
resource "aws_s3_bucket" "aws_storage" {
  bucket = local.s3_bucket_name
  force_destroy = true

  tags = local.common_tags  
}

# aws_s3_policy
resource "aws_s3_bucket_policy" "aws_storage_policy" {
  bucket = aws_s3_bucket.aws_storage.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.aws_storage.id}/*"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.aws_storage.id}"
        },
        {
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${aws_s3_bucket.aws_storage.id}/*"
        }
    ]
}
POLICY
}

# aws_s3_object
resource "aws_s3_object" "aws_storage_object" {
  bucket = aws_s3_bucket.aws_storage.id
  key    = "example.txt"
  content = "This is an example file uploaded to S3 bucket using Terraform."
  acl    = "private"

  tags = local.common_tags
}