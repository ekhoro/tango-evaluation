# S3 Bucket Resource with recommended configurations
resource "awscc_s3_bucket" "example_bucket" {
  bucket_name = "example-bucket-unique-12345"
  
  # Standard encryption using AWS managed keys
  bucket_encryption = {
    server_side_encryption_configuration = [
      {
        server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
      }
    ]
  }
  
  # Public access block configuration (recommended security settings)
  public_access_block_configuration = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
  
  # Versioning enabled for improved data protection
  versioning_configuration = {
    status = "Enabled"
  }
  
  # Standard tags
  tags = [
    {
      key   = "Environment"
      value = "Production"
    },
    {
      key   = "Name"
      value = "example-bucket"
    }
  ]
}

# Output the bucket name and ARN
output "bucket_name" {
  value       = awscc_s3_bucket.example_bucket.bucket_name
  description = "The name of the created S3 bucket"
}

output "bucket_arn" {
  value       = awscc_s3_bucket.example_bucket.arn
  description = "The ARN of the created S3 bucket"
}
