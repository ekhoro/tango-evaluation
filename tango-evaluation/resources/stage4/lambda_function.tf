# Configure AWS provider
provider "aws" {
  region = "us-west-2"
}

provider "awscc" {
  region = "us-west-2"
}

# Supporting IAM role for Lambda execution
resource "aws_iam_role" "lambda_execution_role" {
  name = "example-lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_execution" {
  role       = aws_iam_role.lambda_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# AWS Lambda function using AWSCC provider
resource "awscc_lambda_function" "example" {
  function_name = "example-lambda-function"
  description   = "Example Lambda function created with Terraform AWSCC provider"
  
  handler  = "index.handler"
  runtime  = "nodejs18.x"
  role     = aws_iam_role.lambda_execution_role.arn
  
  code = {
    zip_file = filebase64("${path.module}/lambda_function_payload.zip")
  }
  
  memory_size = 128
  timeout     = 3
  
  environment = {
    variables = {
      Environment = "example"
      Name        = "example-lambda-function"
    }
  }
  
  # AWSCC provider requires tags as a list of objects with key/value pairs
  tags = [
    {
      key   = "Environment"
      value = "example"
    },
    {
      key   = "Name"
      value = "example-lambda-function"
    }
  ]
}

# Create a versions.tf file for specifying required providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.49.0"
    }
  }
  required_version = ">= 1.0.0"
}
