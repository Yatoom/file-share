// Policy that allows Lambda to assume a certain role
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

// The role that the lambda function will take
resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"

  // The policy defined earlier allows Lambda to assume this role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

// The empty lambda function resource
resource "aws_lambda_function" "lambda" {
  function_name = "lambda_function_name"
  role          = aws_iam_role.iam_for_lambda.arn
  runtime       = "provided.al2"
  s3_bucket      = 
}