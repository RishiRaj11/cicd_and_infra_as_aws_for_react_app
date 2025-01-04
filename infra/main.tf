provider "aws" {
  region = "us-east-1"  # You can change the region if needed
}

# 1. Create IAM User for S3 Access
resource "aws_iam_user" "s3_user" {
  name = "s3-web-hosting-user"

  tags = {
    Name        = "S3WebHostingUser"
    Environment = "Production"
  }
}

# 2. Create IAM Policy for S3 Bucket Read/Write Access (without Principal)
data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    actions   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.react_app_bucket.bucket}/*"]

    effect = "Allow"
  }
}

resource "aws_iam_policy" "s3_bucket_policy" {
  name        = "S3BucketReadWritePolicy"
  description = "Read and write access to the S3 bucket for static website hosting"
  policy      = data.aws_iam_policy_document.s3_bucket_policy.json
}

# Attach the policy to the IAM User
resource "aws_iam_policy_attachment" "s3_user_attachment" {
  name       = "s3-web-hosting-policy-attachment"
  users      = [aws_iam_user.s3_user.name]
  policy_arn = aws_iam_policy.s3_bucket_policy.arn
}

# 3. Create Access Key for IAM User
resource "aws_iam_access_key" "github_action_access_key" {
  user = aws_iam_user.s3_user.name
}

# 4. Create S3 Bucket for Static Website Hosting
resource "aws_s3_bucket" "react_app_bucket" {
  bucket = "my-react-app-unique-name"  # Ensure this name is globally unique

  tags = {
    Name        = "MyReactApp"
    Environment = "Production"
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# 5. Set Public Access Block for S3 Bucket
resource "aws_s3_bucket_public_access_block" "react_app_bucket_block" {
  bucket = aws_s3_bucket.react_app_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# 6. Add Bucket Policy for Public Access
data "aws_iam_policy_document" "react_app_bucket_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.react_app_bucket.bucket}/*"]

    effect = "Allow"

    # Here, directly specify the Principal as "*" for public access
    principals {
      type        = "AWS"
      identifiers = ["*"]  # Allow public access
    }
  }
}

resource "aws_s3_bucket_policy" "react_app_bucket_policy" {
  bucket = aws_s3_bucket.react_app_bucket.id
  policy = data.aws_iam_policy_document.react_app_bucket_policy.json
}