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

# Create an AIOps Investigation Group using AWS Cloud Control API
resource "awscc_aiops_investigation_group" "example_investigation_group" {
  # Required: Name for the investigation group
  name = "example-investigation-group"
  
  # Required: The ARN of the service to associate with this investigation group
  service_arn = "arn:aws:resource-explorer-2:us-west-2:123456789012:service/example-service"
  
  # Required: The ARN of the application to associate with this investigation group
  application_arn = "arn:aws:resource-explorer-2:us-west-2:123456789012:application/example-application"
  
  # Optional: Tags for the investigation group
  tags = {
    Environment = "Development"
    Project     = "Example"
  }
}

# Output the investigation group ARN and ID
output "investigation_group_arn" {
  value = awscc_aiops_investigation_group.example_investigation_group.arn
}

output "investigation_group_id" {
  value = awscc_aiops_investigation_group.example_investigation_group.id
}
