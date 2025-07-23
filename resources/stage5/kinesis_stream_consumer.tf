# Kinesis Stream resource
resource "awscc_kinesis_stream" "example_stream" {
  name                 = "example-stream"
  retention_period_hours = 24
  shard_count          = 1
  
  tags = [
    {
      key   = "Environment"
      value = "example"
    },
    {
      key   = "Name"
      value = "example-stream"
    }
  ]
}

# Kinesis Stream Consumer resource
resource "awscc_kinesis_stream_consumer" "example_consumer" {
  consumer_name = "example-consumer"
  stream_arn    = awscc_kinesis_stream.example_stream.arn
  
  tags = [
    {
      key   = "Environment"
      value = "example"
    },
    {
      key   = "Name"
      value = "example-consumer"
    }
  ]
}

# Output the ARN of the consumer
output "consumer_arn" {
  description = "The ARN of the Kinesis Stream Consumer"
  value       = awscc_kinesis_stream_consumer.example_consumer.consumer_arn
}
