# IAM role for the Lambda function
resource "awscc_iam_role" "example_lambda_role" {
  role_name = "example-lambda-role"
  assume_role_policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  ]
  tags = [
    {
      key   = "Environment"
      value = "Example"
    },
    {
      key   = "Name"
      value = "example-lambda-role"
    }
  ]
}

# Lambda function with inline code
resource "awscc_lambda_function" "example_function" {
  function_name = "example-function"
  role          = awscc_iam_role.example_lambda_role.arn
  
  handler  = "index.handler"
  runtime  = "nodejs20.x"
  timeout  = 30
  memory_size = 256
  
  code = {
    zip_file = <<EOF
exports.handler = async (event) => {
  console.log('Event: ', JSON.stringify(event, null, 2));
  return {
    statusCode: 200,
    body: JSON.stringify('Hello from Lambda!'),
  };
};
EOF
  }

  environment = {
    variables = {
      ENVIRONMENT = "example"
    }
  }
  
  architectures = ["x86_64"]
  
  tags = [
    {
      key   = "Environment"
      value = "Example"
    },
    {
      key   = "Name"
      value = "example-function"
    }
  ]
}

output "lambda_function_arn" {
  value = awscc_lambda_function.example_function.arn
}
