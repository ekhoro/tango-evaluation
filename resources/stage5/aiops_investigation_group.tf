# IAM Role for the investigation group
resource "awscc_iam_role" "example_investigation_role" {
  role_name = "example-aiops-investigation-role"
  
  assume_role_policy_document = jsonencode({
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
}

# Attach the required policies to the role
resource "awscc_iam_role_policy" "cloudwatch_attachment" {
  policy_name = "cloudwatch-access"
  role_name   = awscc_iam_role.example_investigation_role.role_name
  
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "cloudwatch:*",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "awscc_iam_role_policy" "cloudtrail_attachment" {
  policy_name = "cloudtrail-access"
  role_name   = awscc_iam_role.example_investigation_role.role_name
  
  policy_document = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "cloudtrail:Get*",
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = "cloudtrail:Describe*",
        Effect = "Allow",
        Resource = "*"
      },
      {
        Action = "cloudtrail:List*",
        Effect = "Allow",
        Resource = "*"
      }
    ]
  })
}

# AIOps Investigation Group
resource "awscc_aiops_investigation_group" "example" {
  name                               = "example-investigation-group"
  role_arn                           = awscc_iam_role.example_investigation_role.arn
  retention_in_days                  = 90
  is_cloud_trail_event_history_enabled = true
  
  tags = [
    {
      key   = "Environment"
      value = "Development"
    },
    {
      key   = "Name"
      value = "example-investigation-group"
    }
  ]
}

# Output the investigation group ARN
output "investigation_group_arn" {
  value = awscc_aiops_investigation_group.example.arn
}
