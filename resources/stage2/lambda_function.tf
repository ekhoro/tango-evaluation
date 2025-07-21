terraform {
  required_version = ">= 1.0.0"
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.65.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4.0"
    }
  }
}

provider "awscc" {
  region = var.aws_region
}

# Random ID for unique function naming
resource "random_id" "function_suffix" {
  byte_length = 4
}

# Create ZIP file for Lambda function code
data "archive_file" "lambda_code" {
  type        = "zip"
  output_path = "${path.module}/lambda_function_${random_id.function_suffix.hex}.zip"
  
  source {
    content  = <<-EOF
      exports.handler = async (event) => {
        console.log('Event: ', JSON.stringify(event, null, 2));
        return {
          statusCode: 200,
          body: JSON.stringify({
            message: 'Hello from Lambda!',
            stage: process.env.STAGE
          })
        };
      };
    EOF
    filename = "index.js"
  }
}

# IAM Role for Lambda execution
resource "awscc_iam_role" "lambda_execution_role" {
  role_name = "lambda-execution-role-${random_id.function_suffix.hex}"
  
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
  
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  
  tags = [
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "Stage"
      value = var.stage
    }
  ]
}

# Lambda function using AWS Cloud Control API
resource "awscc_lambda_function" "example_function" {
  function_name = "${var.function_name_prefix}-${var.stage}-${random_id.function_suffix.hex}"
  
  code = {
    zip_file = filebase64(data.archive_file.lambda_code.output_path)
  }
  
  role = awscc_iam_role.lambda_execution_role.arn
  
  runtime = var.lambda_runtime
  handler = "index.handler"
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
  
  environment = {
    variables = {
      STAGE = var.stage
      ENV   = var.environment
    }
  }
  
  tracing_config = {
    mode = var.enable_xray ? "Active" : "PassThrough"
  }
  
  tags = [
    {
      key   = "Environment"
      value = var.environment
    },
    {
      key   = "Stage"
      value = var.stage
    },
    {
      key   = "Name"
      value = "${var.function_name_prefix}-${var.stage}"
    }
  ]
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "function_name_prefix" {
  description = "Prefix for the Lambda function name"
  type        = string
  default     = "awscc-example"
}

variable "lambda_runtime" {
  description = "Runtime for the Lambda function"
  type        = string
  default     = "nodejs18.x"
}

variable "lambda_timeout" {
  description = "Timeout for the Lambda function in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory size for the Lambda function in MB"
  type        = number
  default     = 128
}

variable "enable_xray" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = false
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
  default     = "dev"
}

variable "stage" {
  description = "Deployment stage (dev, test, prod)"
  type        = string
  default     = "dev"
}

# Outputs
output "function_id" {
  description = "The ID of the Lambda function"
  value       = awscc_lambda_function.example_function.id
}

output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = awscc_lambda_function.example_function.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = awscc_lambda_function.example_function.function_name
}


