#!/bin/bash

# AWSCC Example Validation Script
# Usage: ./validate.sh <terraform-file>

set -e

if [ $# -eq 0 ]; then
    echo "Usage: $0 <terraform-file>"
    echo "Example: $0 my-example.tf"
    exit 1
fi

TERRAFORM_FILE="$1"

if [ ! -f "$TERRAFORM_FILE" ]; then
    echo "Error: File '$TERRAFORM_FILE' not found"
    exit 1
fi

echo "🔍 Validating Terraform file: $TERRAFORM_FILE"
echo "================================================"

# Create temporary directory for validation
TEMP_DIR=$(mktemp -d)
cp "$TERRAFORM_FILE" "$TEMP_DIR/"
cd "$TEMP_DIR"

echo "📦 Initializing Terraform..."
if terraform init -no-color; then
    echo "✅ Terraform initialization successful"
else
    echo "❌ Terraform initialization failed"
    exit 1
fi

echo ""
echo "🔧 Validating configuration..."
if terraform validate -no-color; then
    echo "✅ Terraform validation successful"
else
    echo "❌ Terraform validation failed"
    exit 1
fi

echo ""
echo "📋 Generating plan..."
if terraform plan -no-color > plan.out 2>&1; then
    echo "✅ Terraform plan successful"
    echo ""
    echo "📄 Plan summary:"
    grep -E "(Plan:|No changes)" plan.out || echo "Plan generated successfully"
else
    echo "❌ Terraform plan failed"
    echo "Error details:"
    cat plan.out
    exit 1
fi

# Cleanup
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Validation complete! Your Terraform file is ready to use."
echo ""

