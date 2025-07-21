terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "awscc" {
  region = "us-east-1"
}

provider "aws" {
  region = "us-east-1"
}

# IAM role for Lambda execution
resource "aws_iam_role" "example" {
  name = "example-lambda-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach basic Lambda execution policy
resource "aws_iam_role_policy_attachment" "example" {
  role       = aws_iam_role.example.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambda function using AWSCC provider
resource "awscc_lambda_function" "example" {
  function_name = "example-function"
  description   = "Example Lambda function created with AWSCC provider"
  role          = aws_iam_role.example.arn
  
  runtime     = "python3.10"
  handler     = "index.handler"
  memory_size = 128
  timeout     = 30
  
  code = {
    zip_file = <<EOT
def handler(event, context):
    print("Hello from Lambda!")
    return {
        'statusCode': 200,
        'body': 'Function executed successfully!'
    }
EOT
  }
  
  environment = {
    variables = {
      ENVIRONMENT = "production"
      LOG_LEVEL   = "INFO"
    }
  }
  
  tracing_config = {
    mode = "Active"
  }
  
  tags = [{
    key   = "Environment"
    value = "Production"
  }, {
    key   = "Service"
    value = "Example"
  }]
}
