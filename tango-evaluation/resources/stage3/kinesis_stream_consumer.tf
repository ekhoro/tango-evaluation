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

# Create a Kinesis data stream first
resource "aws_kinesis_stream" "example" {
  name             = "example-stream"
  shard_count      = 1
  retention_period = 24
  
  stream_mode_details {
    stream_mode = "PROVISIONED"
  }
  
  tags = {
    Environment = "Production"
    Service     = "DataPipeline"
  }
}

# Create a Kinesis stream consumer using AWSCC provider
resource "awscc_kinesis_stream_consumer" "example" {
  consumer_name = "example-consumer"
  stream_arn    = aws_kinesis_stream.example.arn
}
