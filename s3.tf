resource "aws_s3_bucket" "lep_demo" {
   bucket = var.bucket_name
   acl    = "private"

   server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

   versioning {
     enabled = true
   }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.lep_demo.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.source.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = ""
    filter_suffix       = ".csv"
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}

data "aws_iam_policy_document" "s3_sse_policy" {
  statement {
    actions   = ["s3:PutObject"]
    # resources = ["arn:aws:s3:::my-s3-bucket/*"]
    resources = var.bucket_name
    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = ["AES256"]
    }
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = var.bucket_name

  policy = data.aws_iam_policy_document.s3_sse_policy.json
}


