# data "archive_file" "lambda_zip" {
#   type        = "zip"
#   source_dir = "${path.module}/lambda"
#   output_path = "${path.module}/lambda_function_payload.zip"
# }

resource "aws_iam_role" "lambda_role" {
  name = "lambda_glue_catalog_change_role"

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

resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Action   = "glue:*",
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_lambda_function" "glue_catalog_change" {
  filename                       = "${path.module}/lambda/lambda_function.zip"
  function_name                  = "glue_catalog_change_handler"
  role                           = aws_iam_role.lambda_role.arn
  handler                        = "main.handler"
  runtime                        = "python3.12"
  timeout                        = 30
  reserved_concurrent_executions = 1
  environment {
    variables = {
      SNOWFLAKE_ACCOUNT   = var.snowflake_account
      SNOWFLAKE_USER      = var.snowflake_user
      SNOWFLAKE_PASSWORD  = var.snowflake_password
      SNOWFLAKE_DATABASE  = var.snowflake_database
      SNOWFLAKE_ROLE      = var.snowflake_role
      SNOWFLAKE_WAREHOUSE = var.snowflake_warehouse
    }
  }

  source_code_hash = filebase64sha256("${path.module}/lambda/lambda_function.zip")
}

resource "aws_cloudwatch_event_rule" "glue_catalog_change_rule" {
  name        = "glue_catalog_change_rule"
  description = "Triggered when Glue Data Catalog table changes"
  event_pattern = jsonencode({
    "source" : ["aws.glue"],
    "detail-type" : ["Glue Data Catalog Table State Change"]
  })
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.glue_catalog_change_rule.name
  target_id = "lambda_target"
  arn       = aws_lambda_function.glue_catalog_change.arn
}

resource "aws_lambda_permission" "allow_cloudwatch" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.glue_catalog_change.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.glue_catalog_change_rule.arn
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.glue_catalog_change.function_name}"
  retention_in_days = 1
}
