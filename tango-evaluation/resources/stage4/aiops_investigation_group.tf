# AWS CloudControl (AWSCC) Provider Terraform Configuration
# Resource: awscc_aiops_investigation_group

terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.49.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "awscc" {
  region = "us-east-1"  # Modify as needed
}

provider "aws" {
  region = "us-east-1"  # Modify as needed
}

# Create IAM role for the investigation group
resource "aws_iam_role" "aiops_investigation_role" {
  name = "aiops-investigation-role-example"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "aiops.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "aiops-investigation-role"
  }
}

# Attach required policy to the IAM role
resource "aws_iam_role_policy_attachment" "cloudwatch_read_only" {
  role       = aws_iam_role.aiops_investigation_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}

# CloudWatch Investigations AIOps resource
resource "awscc_aiops_investigation_group" "example" {
  name = "example-investigation-group"
  
  # Enable CloudTrail event history
  is_cloud_trail_event_history_enabled = true
  
  # Set retention in days (how long investigation data is kept)
  retention_in_days = 90
  
  # Reference the IAM role ARN
  role_arn = aws_iam_role.aiops_investigation_role.arn
  
  # Add tags
  tags = [
    {
      key   = "Environment"
      value = "Example"
    },
    {
      key   = "Name"
      value = "example-investigation-group"
    }
  ]

  depends_on = [
    aws_iam_role_policy_attachment.cloudwatch_read_only
  ]
}

# Output the ARN of the investigation group
output "investigation_group_arn" {
  value = awscc_aiops_investigation_group.example.arn
}

output "role_arn" {
  value = aws_iam_role.aiops_investigation_role.arn
}
