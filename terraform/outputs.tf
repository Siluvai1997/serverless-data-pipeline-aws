output "s3_bucket_name" {
  value = aws_s3_bucket.data_bucket.id
}

output "lambda_function_name" {
  value = aws_lambda_function.data_transformer.function_name
}