resource "aws_s3_bucket" "test_results_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "test_results_acl" {
  bucket = aws_s3_bucket.test_results_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_cors_configuration" "test_results_bucket_cors" {
  bucket = aws_s3_bucket.test_results_bucket.bucket

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = [
      "POST", "GET", "PUT", "DELETE", "HEAD"
    ]
    allowed_origins = ["*"]
  }
}

resource "aws_s3_bucket_public_access_block" "sorry_cypress" {
  bucket = aws_s3_bucket.test_results_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "sorry_cypress" {
  bucket = aws_s3_bucket.test_results_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
    bucket_key_enabled = true
  }
}
