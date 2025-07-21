# Provider configuration
terraform {
  required_providers {
    awscc = {
      source  = "hashicorp/awscc"
      version = "~> 1.49.0"  # Using the latest version as specified
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"  # Change to your preferred region
}

provider "awscc" {
  region = "us-east-1"  # Change to your preferred region
}

# Create a VPC for the App Runner VPC Connector
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "example-vpc"
    Environment = "Production"
  }
}

# Create two subnets in different AZs for high availability
resource "aws_subnet" "example_subnet_1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"  # Change according to your region
  
  tags = {
    Name        = "example-subnet-1"
    Environment = "Production"
  }
}

resource "aws_subnet" "example_subnet_2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"  # Change according to your region
  
  tags = {
    Name        = "example-subnet-2"
    Environment = "Production"
  }
}

# Create a security group for the App Runner VPC Connector
resource "aws_security_group" "example" {
  name        = "example-vpc-connector-sg"
  description = "Security group for App Runner VPC connector"
  vpc_id      = aws_vpc.example.id
  
  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "example-vpc-connector-sg"
    Environment = "Production"
  }
}

# App Runner VPC Connector
resource "awscc_apprunner_vpc_connector" "example" {
  vpc_connector_name = "example-vpc-connector"
  subnets           = [
    aws_subnet.example_subnet_1.id,
    aws_subnet.example_subnet_2.id
  ]
  security_groups   = [aws_security_group.example.id]
  
  tags = [
    {
      key   = "Environment"
      value = "Production"
    },
    {
      key   = "Name"
      value = "example-vpc-connector"
    }
  ]
}

# Data source to retrieve the VPC connector information
data "awscc_apprunner_vpc_connector" "example" {
  id = awscc_apprunner_vpc_connector.example.id
  depends_on = [awscc_apprunner_vpc_connector.example]
}

# Output the VPC connector ARN
output "vpc_connector_arn" {
  value = awscc_apprunner_vpc_connector.example.vpc_connector_arn
}
