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

# Random ID for unique connector naming
resource "random_id" "connector_suffix" {
  byte_length = 4
}

# VPC for the connector
resource "awscc_ec2_vpc" "app_vpc" {
  cidr_block = var.vpc_cidr
  
  tags = [
    {
      key   = "Name"
      value = "${var.resource_prefix}-vpc-${var.stage}"
    },
    {
      key   = "Environment"
      value = var.environment
    }
  ]
}

# Subnets for the VPC connector
resource "awscc_ec2_subnet" "app_subnet_1" {
  vpc_id            = awscc_ec2_vpc.app_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = "${var.aws_region}a"
  
  tags = [
    {
      key   = "Name"
      value = "${var.resource_prefix}-subnet-1-${var.stage}"
    }
  ]
}

resource "awscc_ec2_subnet" "app_subnet_2" {
  vpc_id            = awscc_ec2_vpc.app_vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, 2)
  availability_zone = "${var.aws_region}b"
  
  tags = [
    {
      key   = "Name"
      value = "${var.resource_prefix}-subnet-2-${var.stage}"
    }
  ]
}

# Security Group for the VPC connector
resource "awscc_ec2_securitygroup" "app_sg" {
  vpc_id      = awscc_ec2_vpc.app_vpc.id
  group_name  = "${var.resource_prefix}-sg-${var.stage}-${random_id.connector_suffix.hex}"
  group_description = "Security group for AppRunner VPC connector"
  
  security_group_ingress = [
    {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all inbound traffic"
    }
  ]
  
  security_group_egress = [
    {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all outbound traffic"
    }
  ]
  
  tags = [
    {
      key   = "Name"
      value = "${var.resource_prefix}-sg-${var.stage}"
    }
  ]
}

# AppRunner VPC Connector
resource "awscc_apprunner_vpc_connector" "example_connector" {
  vpc_connector_name = "${var.resource_prefix}-connector-${var.stage}-${random_id.connector_suffix.hex}"
  subnets            = [
    awscc_ec2_subnet.app_subnet_1.id,
    awscc_ec2_subnet.app_subnet_2.id
  ]
  security_groups    = [
    awscc_ec2_security_group.app_sg.id
  ]
  
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

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "apprunner"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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
output "vpc_connector_id" {
  description = "The ID of the AppRunner VPC connector"
  value       = awscc_apprunner_vpc_connector.example_connector.id
}

output "vpc_connector_arn" {
  description = "The ARN of the AppRunner VPC connector"
  value       = awscc_apprunner_vpc_connector.example_connector.vpc_connector_arn
}

output "vpc_connector_status" {
  description = "The status of the AppRunner VPC connector"
  value       = awscc_apprunner_vpc_connector.example_connector.status
}

output "vpc_connector_revision" {
  description = "The revision of the AppRunner VPC connector"
  value       = awscc_apprunner_vpc_connector.example_connector.vpc_connector_revision
}
