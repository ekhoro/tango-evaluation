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

# Create a Kinesis Stream Consumer using AWS Cloud Control API
resource "awscc_kinesis_stream_consumer" "example_consumer" {
  # Required: The ARN of the Kinesis data stream to register the consumer with
  stream_arn = "arn:aws:kinesis:us-west-2:123456789012:stream/example-kinesis-stream"
  
  # Required: The name of the consumer
  consumer_name = "example-stream-consumer"
}

# Output the consumer ARN and creation timestamp
output "consumer_arn" {
  value = awscc_kinesis_stream_consumer.example_consumer.consumer_arn
}

output "consumer_creation_timestamp" {
  value = awscc_kinesis_stream_consumer.example_consumer.consumer_creation_timestamp
}
