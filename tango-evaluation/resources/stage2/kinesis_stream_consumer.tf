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
  }
}

provider "awscc" {
  region = var.aws_region
}

# Random ID for unique stream naming
resource "random_id" "stream_suffix" {
  byte_length = 4
}

# Kinesis Data Stream
resource "awscc_kinesis_stream" "example_stream" {
  name              = "${var.stream_name_prefix}-${var.stage}-${random_id.stream_suffix.hex}"
  retention_period_hours = var.retention_period_hours
  shard_count       = var.shard_count
  
  stream_encryption = {
    encryption_type = "KMS"
    key_id          = "alias/aws/kinesis"
  }
  
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

# Kinesis Stream Consumer
resource "awscc_kinesis_stream_consumer" "example_consumer" {
  consumer_name     = "${var.consumer_name_prefix}-${var.stage}"
  stream_arn        = awscc_kinesis_stream.example_stream.arn
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "stream_name_prefix" {
  description = "Prefix for the Kinesis stream name"
  type        = string
  default     = "data-stream"
}

variable "consumer_name_prefix" {
  description = "Prefix for the Kinesis stream consumer name"
  type        = string
  default     = "app-consumer"
}

variable "retention_period_hours" {
  description = "Number of hours for data retention in the stream"
  type        = number
  default     = 24
}

variable "shard_count" {
  description = "Number of shards for the Kinesis stream"
  type        = number
  default     = 1
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
output "stream_id" {
  description = "The ID of the Kinesis stream"
  value       = awscc_kinesis_stream.example_stream.id
}

output "stream_arn" {
  description = "The ARN of the Kinesis stream"
  value       = awscc_kinesis_stream.example_stream.arn
}

output "stream_name" {
  description = "The name of the Kinesis stream"
  value       = awscc_kinesis_stream.example_stream.name
}

output "consumer_arn" {
  description = "The ARN of the Kinesis stream consumer"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_arn
}

output "consumer_name" {
  description = "The name of the Kinesis stream consumer"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_name
}

output "consumer_creation_timestamp" {
  description = "The timestamp when the consumer was created"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_creation_timestamp
}
