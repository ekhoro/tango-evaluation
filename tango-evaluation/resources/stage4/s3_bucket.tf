terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.49.0"
    }
  }
}

provider "awscc" {
  region = "us-west-2"
}

resource "awscc_s3_bucket" "example" {
  bucket_name = "example-awscc-bucket-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  
  tags = [
    {
      key   = "Environment"
      value = "Test"
    },
    {
      key   = "Name"
      value = "AWSCC Example Bucket"
    }
  ]
  
  public_access_block_configuration = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}

output "bucket_name" {
  value = awscc_s3_bucket.example.bucket_name
}

output "bucket_arn" {
  value = awscc_s3_bucket.example.arn
}
