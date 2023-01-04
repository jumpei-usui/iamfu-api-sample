resource "aws_s3_bucket" "image_bucket" {
  bucket = var.image_bucket_name
}

resource "aws_s3_bucket_acl" "image_bucket_acl" {
  bucket = aws_s3_bucket.image_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = var.lambda_bucket_name
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}
