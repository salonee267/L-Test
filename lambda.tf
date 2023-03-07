
data "archive_file" "source" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_function"
  output_path = "${path.module}/lambda_function.zip"
}

resource "aws_lambda_function" "source" {
  filename         = "lambda_function.zip"
  source_code_hash = "${data.archive_file.source.output_base64sha256}"
  function_name    = "connect_rds"
  role             = "arn:aws:iam::645240902082:role/LambdaRoleForS3andRDS"
  handler          = "connect_to_rds.lambda_handler"
  runtime          = "python3.8"
  timeout          = 120

  # lifecycle {
  #   ignore_changes = ["source_code_hash"]
  # }
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.source.arn
  principal     = "s3.amazonaws.com"
  source_arn    =  aws_s3_bucket.lep_demo.arn
}