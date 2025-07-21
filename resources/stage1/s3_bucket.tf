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

# Create an S3 bucket using AWS Cloud Control API
resource "awscc_s3_bucket" "example_bucket" {
  bucket_name = "example-bucket-name"
  
  # Required access control settings
  access_control = {
    public_access_block_configuration = {
      block_public_acls       = true
      block_public_policy     = true
      ignore_public_acls      = true
      restrict_public_buckets = true
    }
  }
  
  # Required notification configuration (can be empty but must be defined)
  notification_configuration = {}
  
  # Required website configuration (can be empty but must be defined)
  website_configuration = {}
  
  # Tags for the bucket
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

# Output the bucket name and ARN
output "bucket_name" {
  value = awscc_s3_bucket.example_bucket.bucket_name
}

output "bucket_arn" {
  value = awscc_s3_bucket.example_bucket.arn
}
