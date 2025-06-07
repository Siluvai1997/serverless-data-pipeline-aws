provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "serverless-pipeline-demo-data"
  force_destroy = true
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_exec" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "data_transformer" {
  filename         = "${path.module}/../lambda/lambda.zip"
  function_name    = "data-transformer-fn"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "transform.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = filebase64sha256("${path.module}/../lambda/lambda.zip")
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.data_transformer.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.data_bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.data_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.data_transformer.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_glue_catalog_database" "analytics_db" {
  name = "serverless_pipeline_db"
}

resource "aws_glue_crawler" "s3_crawler" {
  name          = "serverless-s3-crawler"
  role          = aws_iam_role.lambda_exec_role.arn
  database_name = aws_glue_catalog_database.analytics_db.name

  s3_target {
    path = "s3://${aws_s3_bucket.data_bucket.id}/processed/"
  }

  schedule = "cron(0 * * * ? *)"
}

resource "aws_athena_workgroup" "default" {
  name = "serverless_pipeline_wg"
  configuration {
    enforce_workgroup_configuration = true
    result_configuration {
      output_location = "s3://${aws_s3_bucket.data_bucket.id}/athena_results/"
    }
  }
}