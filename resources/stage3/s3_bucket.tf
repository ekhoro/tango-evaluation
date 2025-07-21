terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.0"
    }
  }
}

provider "awscc" {
  region = "us-east-1"
}

resource "awscc_s3_bucket" "example" {
  bucket_name = "example-unique-bucket-name-20240718"
  
  notification_configuration = {
    topic_configurations = [{
      event = "s3:ObjectCreated:*"
      topic = "arn:aws:sns:us-east-1:123456789012:example-topic"
    }]
  }
  
  lifecycle_configuration = {
    rules = [{
      id     = "archive-rule"
      status = "Enabled"
      transitions = [{
        storage_class = "GLACIER"
        transition_in_days = 90
      }]
    }]
  }
  
  versioning_configuration = {
    status = "Enabled"
  }
  
  tags = [{
    key   = "Environment"
    value = "Production"
  }, {
    key   = "Name"
    value = "Example S3 Bucket"
  }]
}
