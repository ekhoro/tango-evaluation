terraform {
  required_version = ">= 1.0.0"
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 0.70.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "awscc" {
  region = var.aws_region
}

provider "aws" {
  region = var.aws_region
}

# Random suffix for unique naming
resource "random_id" "suffix" {
  byte_length = 4
}

# IAM Role for AIOps Investigation Group
resource "aws_iam_role" "aiops_investigation_role" {
  name = "aiops-investigation-role-${random_id.suffix.hex}"
  
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

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonCloudWatchFullAccess",
    "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
  ]

  tags = var.tags
}

# AIOps Investigation Group
resource "awscc_aiops_investigation_group" "example" {
  name                              = var.investigation_group_name
  role_arn                          = aws_iam_role.aiops_investigation_role.arn
  retention_in_days                 = var.retention_in_days
  is_cloud_trail_event_history_enabled = var.enable_cloudtrail_event_history
  
  encryption_configuration = {
    type      = var.encryption_type
    kms_key_id = var.kms_key_id != "" ? var.kms_key_id : null
  }
  
  tags = var.tags
}

# Variables
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "investigation_group_name" {
  description = "Name for the AIOps Investigation Group"
  type        = string
  default     = "example-investigation-group"
}

variable "retention_in_days" {
  description = "Number of days to retain investigation data"
  type        = number
  default     = 90
}

variable "enable_cloudtrail_event_history" {
  description = "Whether to enable CloudTrail event history for investigations"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Type of encryption to use for investigation data"
  type        = string
  default     = "AWS_OWNED_KEY"
  validation {
    condition     = contains(["AWS_OWNED_KEY", "CUSTOMER_MANAGED_KMS_KEY"], var.encryption_type)
    error_message = "Encryption type must be either AWS_OWNED_KEY or CUSTOMER_MANAGED_KMS_KEY."
  }
}

variable "kms_key_id" {
  description = "KMS key ID to use for encryption when using CUSTOMER_MANAGED_KMS_KEY"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {
    Environment = "dev"
    ManagedBy   = "terraform"
  }
}

# Outputs
output "investigation_group_arn" {
  description = "ARN of the created AIOps Investigation Group"
  value       = awscc_aiops_investigation_group.example.arn
}

output "investigation_group_id" {
  description = "ID of the created AIOps Investigation Group"
  value       = awscc_aiops_investigation_group.example.id
}
