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

# Create VPC and subnets for the VPC connector
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "example-vpc"
  }
}

resource "aws_subnet" "example1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "example-subnet-1"
  }
}

resource "aws_subnet" "example2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "example-subnet-2"
  }
}

# Create security group for the VPC connector
resource "aws_security_group" "example" {
  name        = "example-apprunner-sg"
  description = "Security group for App Runner VPC connector"
  vpc_id      = aws_vpc.example.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "example-apprunner-sg"
  }
}

# Create App Runner VPC connector
resource "awscc_apprunner_vpc_connector" "example" {
  vpc_connector_name = "example-vpc-connector"
  subnets            = [
    aws_subnet.example1.id,
    aws_subnet.example2.id
  ]
  security_groups    = [
    aws_security_group.example.id
  ]
  
  tags = [{
    key   = "Environment"
    value = "Production"
  }, {
    key   = "Service"
    value = "AppRunner"
  }]
}
