resource "aws_s3_bucket" "test_results_bucket" {
  bucket = var.s3_bucket_name
}

resource "aws_s3_bucket_acl" "test_results_acl" {
  bucket = aws_s3_bucket.test_results_bucket.id
  access_control_policy {
    grant {
      grantee {
        id   = data.aws_canonical_user_id.current.id
        type = "CanonicalUser"
      }
      permission = "FULL_CONTROL"
    }
    owner {
      id = data.aws_canonical_user_id.current.id
    }
  }
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

  block_public_acls       = false
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "tests_retention_policy" {
  bucket = aws_s3_bucket.test_results_bucket.bucket
  rule {
    id     = "retention_policy"
    status = "Enabled"
    expiration {
      days = var.test_results_retention
    }
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_prefix_list" {
  bucket = aws_s3_bucket.test_results_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_prefix_list.json
}

data "aws_ec2_managed_prefix_list" "prefix_list" {
  filter {
    name   = "prefix-list-name"
    values = [var.prefix_list_name]
  }
}

data "aws_iam_policy_document" "allow_access_from_prefix_list" {
  statement {
    sid = "AllowAccessFromPrefixList"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObjectAcl",
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.test_results_bucket.arn,
      "${aws_s3_bucket.test_results_bucket.arn}/*"
    ]
    condition {
      test     = "IpAddress"
      variable = "aws:SourceIp"
      values   = data.aws_ec2_managed_prefix_list.prefix_list.entries[*].cidr
    }
  }
}
