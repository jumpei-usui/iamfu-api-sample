data "archive_file" "lambda_api_function" {
  type = "zip"

  source_dir  = "${path.module}/get-image"
  output_path = "${path.module}/get-image.zip"
}

resource "aws_s3_object" "lambda_api_function" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "get-image.zip"
  source = data.archive_file.lambda_api_function.output_path

  etag = filemd5(data.archive_file.lambda_api_function.output_path)
}

resource "aws_lambda_function" "get_image" {
  function_name = "GetImage"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_api_function.key

  runtime = "python3.9"
  handler = "get_image.lambda_handler"

  source_code_hash = data.archive_file.lambda_api_function.output_base64sha256

  role    = aws_iam_role.lambda_exec.arn
  timeout = 30
}

resource "aws_cloudwatch_log_group" "get_image" {
  name = "/aws/lambda/${aws_lambda_function.get_image.function_name}"

  retention_in_days = 30
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}
