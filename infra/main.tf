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
}

// Create IAM user for deploying to Lambda
resource "aws_iam_user" "lambda-service-user" {
  name = "lambda-service-user"
}

// Access key
resource "aws_iam_access_key" "lambda-service-user" {
  user = aws_iam_user.lambda-service-user.name
}

// Policy for above user
resource "aws_iam_policy" "lambda-service-policy" {
  name   = "lambda-service-policy"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lambda:GetFunction",
          "lambda:GetLayerVersion",
          "lambda:CreateFunction",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:PublishVersion",
          "lambda:TagResource"
        ]
        Resource = [
          aws_lambda_function.arn
        ]
      }
    ]
  })
}

// Connect policy to user
resource "aws_iam_user_policy_attachment" "lambda-service-user-policy-attachment" {
  user = aws_iam_user.lambda-service-user.name
  policy_arn = aws_iam_policy.lambda-service-policy.arn
}

// User to be used by cargo
output "aws_access_key_id" {
  value = aws_iam_access_key.lambda-service-user.id
}

// Key to be used by cargo
output "aws_secret_access_key" {
  value = aws_iam_access_key.lambda-service-user.secret
  sensitive = true
}