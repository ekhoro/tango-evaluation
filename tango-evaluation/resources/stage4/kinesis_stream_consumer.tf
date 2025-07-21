# Configure the AWS Cloud Control Provider
terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.49.0"
    }
  }
}

# Configure the AWS Provider
provider "awscc" {
  region = "us-east-1"
}

# First, we need to create a Kinesis Stream to attach the consumer to
resource "awscc_kinesis_stream" "example_stream" {
  name        = "example-stream"
  shard_count = 1
  retention_period_hours = 24
  
  tags = [
    {
      key   = "Environment"
      value = "Example"
    },
    {
      key   = "Name"
      value = "example-kinesis-stream"
    }
  ]
}

# Create a Kinesis Stream Consumer
resource "awscc_kinesis_stream_consumer" "example_consumer" {
  consumer_name = "example-consumer"
  stream_arn    = awscc_kinesis_stream.example_stream.arn
  
  tags = [
    {
      key   = "Environment"
      value = "Example"
    },
    {
      key   = "Name"
      value = "example-kinesis-consumer"
    }
  ]
}

# Output the consumer ARN and status
output "consumer_arn" {
  description = "The ARN of the created Kinesis stream consumer"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_arn
}

output "consumer_status" {
  description = "The status of the Kinesis stream consumer"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_status
}

output "consumer_creation_timestamp" {
  description = "The timestamp when the consumer was created"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_creation_timestamp
}
