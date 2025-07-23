# Create VPC for the App Runner VPC Connector
resource "aws_vpc" "example" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  
  tags = {
    Name        = "example-vpc"
    Environment = "example"
  }
}

# Create subnets in different availability zones
resource "aws_subnet" "example1" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
  
  tags = {
    Name        = "example-subnet-1"
    Environment = "example"
  }
}

resource "aws_subnet" "example2" {
  vpc_id            = aws_vpc.example.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
  
  tags = {
    Name        = "example-subnet-2"
    Environment = "example"
  }
}

# Create security group for the VPC Connector
resource "aws_security_group" "example" {
  name        = "example-sg"
  description = "Security group for App Runner VPC connector"
  vpc_id      = aws_vpc.example.id
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "example-sg"
    Environment = "example"
  }
}

# App Runner VPC Connector resource
resource "awscc_apprunner_vpc_connector" "example" {
  vpc_connector_name = "example-vpc-connector"
  subnets            = [aws_subnet.example1.id, aws_subnet.example2.id]
  security_groups    = [aws_security_group.example.id]
  
  tags = [
    {
      key   = "Name"
      value = "example-vpc-connector"
    },
    {
      key   = "Environment"
      value = "example"
    }
  ]
}

# Output the VPC Connector ARN
output "vpc_connector_arn" {
  value       = awscc_apprunner_vpc_connector.example.vpc_connector_arn
  description = "The ARN of the App Runner VPC Connector"
}
