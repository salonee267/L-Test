resource "aws_s3_bucket" "lep_demo" {
   bucket = "lep-demo-s3-bucket-1234"
   acl    = "private"

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