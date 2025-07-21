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

# IAM Role for AIOps Investigation Group
resource "aws_iam_role" "example" {
  name = "example-aiops-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "aiops.amazonaws.com"
      }
    }]
  })

  # Attach policies needed for AIOps investigations
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
  ]
  
  tags = {
    Name = "example-aiops-role"
  }
}

# KMS Key for encryption (optional)
resource "aws_kms_key" "example" {
  description             = "KMS key for AIOps investigation data encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  tags = {
    Name = "example-aiops-key"
  }
}

# AIOps Investigation Group
resource "awscc_aiops_investigation_group" "example" {
  name = "example-investigation-group"
  role_arn = aws_iam_role.example.arn
  
  # Optional: Configure data retention (default is 90 days)
  retention_in_days = 120
  
  # Optional: Enable CloudTrail event history
  is_cloud_trail_event_history_enabled = true
  
  # Optional: Configure encryption
  encryption_configuration = {
    type = "CUSTOMER_MANAGED_KMS_KEY"
    kms_key_id = aws_kms_key.example.arn
  }
  
  # Optional: Configure tag key boundaries for resource discovery
  tag_key_boundaries = ["application", "service", "team"]
  
  tags = [{
    key   = "Environment"
    value = "Production"
  }, {
    key   = "Service"
    value = "AIOps"
  }]
}
