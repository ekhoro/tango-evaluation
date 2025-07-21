# Provider configuration for AWS Cloud Control
terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.65.0"
    }
  }
}

# Configure the AWS Cloud Control Provider
provider "awscc" {
  region = "us-west-2"
}

# Create a Lambda function using AWS Cloud Control API
resource "awscc_lambda_function" "example_function" {
  function_name = "example-lambda-function"
  
  # Required code configuration
  code = {
    s3_bucket = "example-code-bucket"
    s3_key    = "lambda-code/function.zip"
  }
  
  # Required runtime
  runtime = "nodejs18.x"
  
  # Required IAM role for Lambda execution
  role = "arn:aws:iam::123456789012:role/lambda-execution-role"
  
  # Required handler
  handler = "index.handler"
  
  # Memory allocation in MB
  memory_size = 128
  
  # Timeout in seconds
  timeout = 30
  
  # Environment variables
  environment = {
    variables = {
      ENV_VAR_1 = "value1"
      ENV_VAR_2 = "value2"
    }
  }
  
  # Tags for the function
  tags = [
    {
      key   = "Environment"
      value = "Development"
    },
    {
      key   = "Project"
      value = "Example"
    }
  ]
}

# Output the function name and ARN
output "function_name" {
  value = awscc_lambda_function.example_function.function_name
}

output "function_arn" {
  value = awscc_lambda_function.example_function.arn
}
