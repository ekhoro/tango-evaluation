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

# Random ID for unique bucket naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# S3 Bucket using AWS Cloud Control API
resource "awscc_s3_bucket" "example_bucket" {
  bucket_name = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
  
  access_control = var.enable_public_access ? "PublicRead" : "Private"
  
  versioning_configuration = {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
  
  bucket_encryption = {
    server_side_encryption_configuration = [
      {
        server_side_encryption_by_default = {
          sse_algorithm = "AES256"
        }
      }
    ]
  }
  
  lifecycle_configuration = {
    rules = [
      {
        id     = "archive-rule"
        status = "Enabled"
        transitions = [
          {
            transition_in_days = var.transition_days
            storage_class = "STANDARD_IA"
          }
        ]
        expiration = {
          days = var.expiration_days
        }
      }
    ]
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

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "bucket_prefix" {
  description = "Prefix for the S3 bucket name"
  type        = string
  default     = "awscc-example"
}

variable "enable_versioning" {
  description = "Enable versioning for the S3 bucket"
  type        = bool
  default     = true
}

variable "enable_public_access" {
  description = "Enable public read access for the S3 bucket"
  type        = bool
  default     = false
}

variable "transition_days" {
  description = "Number of days before transitioning objects to STANDARD_IA"
  type        = number
  default     = 30
}

variable "expiration_days" {
  description = "Number of days before expiring objects"
  type        = number
  default     = 365
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
output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = awscc_s3_bucket.example_bucket.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = awscc_s3_bucket.example_bucket.arn
}

output "bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  value       = awscc_s3_bucket.example_bucket.domain_name
}
