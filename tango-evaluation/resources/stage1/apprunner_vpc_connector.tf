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

# Create an App Runner VPC Connector using AWS Cloud Control API
resource "awscc_apprunner_vpc_connector" "example_connector" {
  vpc_connector_name = "example-vpc-connector"
  
  # Required subnets (at least one subnet ID is required)
  subnets = [
    "subnet-0abc123def456789a",
    "subnet-0bcd234efg567890b"
  ]
  
  # Required security groups (at least one security group ID is required)
  security_groups = [
    "sg-0abc123def456789a",
    "sg-0bcd234efg567890b"
  ]
  
  # Optional tags
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

# Output the VPC connector ARN and ID
output "vpc_connector_arn" {
  value = awscc_apprunner_vpc_connector.example_connector.vpc_connector_arn
}

output "vpc_connector_id" {
  value = awscc_apprunner_vpc_connector.example_connector.id
}
