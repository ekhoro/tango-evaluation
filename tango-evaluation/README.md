# TANGO Evaluation Framework

Evaluation framework for comparing different implementation stages of TANGO (Terraform AI-Native Generator and Orchestrator).

## Implementation Stages

### Stage 1: Simple Q CLI
- Basic Q CLI commands
- No additional context
- Manual validation

Base Prompt:
```
Generate a Terraform usage example for AWS Cloud Control resource "{resource_name}". Include the provider block and all required arguments. Use placeholder values and output the result in Terraform HCL format.
```

### Stage 2: Enhanced Q CLI
- Structured prompts
- Standardized naming
- Technical requirements
- Prerequisites documentation

Base Prompt:
```
Generate a concise Terraform usage example for AWS Cloud Control resource '{RESOURCE_NAME}' with stage variables and method-specific settings if needed. Include the provider block and terraform configuration. Use consistent naming throughout and keep configuration simple but practical.

Technical requirements:
* Use appropriate primary identifier attributes for outputs (verify resource schema for correct attribute names)
* Include all required providers with version constraints  
* Follow AWS Cloud Control provider (awscc) naming conventions
* Ensure terraform validate compatibility
* Include only necessary supporting resources
* Include stage and resource-specific variables for flexibility
* Use random_id for unique naming when needed
* Verify resource-specific attribute support (not all resources support tags, descriptions, or common attributes)
* Research and document any AWS account prerequisites or service setup requirements
* If the resource requires prior AWS account setup, service enablement, or special permissions, include a prerequisites section
* Suggest alternative resources or approaches if prerequisites are complex or restrictive
```

### Stage 3: Context-Based Generation
- Predefined AWSCC documentation context
- Example patterns and templates
- Production-ready standards

Base Context:
- Example patterns for simple and complex resources
- Key principles for resource configuration
- Standard generation rules
- Documentation-focused workflow
- Provider configuration standards
- Consistent naming and tagging conventions
- Resource-specific requirements

The context provides a complete framework for generating examples that align with terraform-provider-awscc documentation patterns, allowing for simpler prompts focused on the specific resource being generated.

### Stage 4: Single Agent

Project TANGO - Terraform AI-Native Generator and Orchestrator with enhanced capabilities:

Core Features:
- Unified agent approach with DynamoDB state management
- Enhanced automation with failure pattern learning
- Comprehensive validation with real AWS deployment testing
- Automated resource discovery and version detection

Implementation Architecture:
1. **State Management (DynamoDB)**
   - Resource state tracking
   - Execution history
   - Failure pattern analysis
   - State persistence across runs

2. **Storage System (S3)**
   - Resource-organized storage
   - Configuration management
   - Output truncation handling
   - Version compatibility tracking

3. **Automation Pipeline**
   - GitHub release monitoring
   - Version detection
   - Resource availability checks
   - Automated cleanup

4. **Validation Process**
   - Multi-phase validation
   - Real AWS deployment testing
   - Resource cleanup verification
   - Comprehensive logging

5. **Smart Processing**
   - Failure pattern learning
   - Resource dependency tracking
   - IAM role management
   - Service compatibility checks

### Stage 5: Multi-Agent Pipeline
- Specialized agents
- Full automation
- Complete validation lifecycle

## Selected Resources

The following AWS resources have been selected for evaluation:

1. **Basic Resources**
   - AWS S3 Bucket (Basic Storage)
   - AWS Lambda Function (Serverless Compute)

2. **Advanced Networking**
   - AWS App Runner VPC Connector (Modern VPC Integration)

3. **Modern Services**
   - AWS Kinesis Stream Consumer (Real-time Data Processing)
   - AWS AIOps Investigation Group (AI Operations)

## Test Results

### Stage 1 Results

1. **Basic Resources**
   - S3 Bucket: ❌ Failed (Schema mismatch)
   - Lambda Function: ⚠️ Partial (Valid config, failed on placeholder IAM role)

2. **Advanced Networking**
   - App Runner VPC Connector: ⚠️ Partial (Valid config, failed on placeholder subnets)

3. **Modern Services**
   - Kinesis Stream Consumer: ❌ Failed (Resource not supported)
   - AIOps Investigation Group: ❌ Failed (Resource not supported)

Success Metrics:
- Configuration Syntax: 40% (2/5)
- Resource Support: 60% (3/5)
- Apply Success: 0% (0/5 attempted)

### Stage 2 Results

1. **Basic Resources**
   - S3 Bucket: ✅ Success (Valid config, successful apply/destroy)
   - Lambda Function: ✅ Success (Valid config, successful apply/destroy)

2. **Advanced Networking**
   - App Runner VPC Connector: ❌ Failed (Invalid resource types for VPC components)

3. **Modern Services**
   - Kinesis Stream Consumer: ❌ Failed (Resource not supported)
   - AIOps Investigation Group: ❌ Failed (Resource not supported)

Success Metrics:
- Configuration Syntax: 100% (5/5)
- Resource Support: 40% (2/5)
- Apply Success: 40% (2/5)

### Stage 3 Results

1. **Basic Resources**
   - S3 Bucket: ❌ Failed (Access denied)
   - Lambda Function: ✅ Success (Valid config, successful apply/destroy)

2. **Advanced Networking**
   - App Runner VPC Connector: ✅ Success (Valid config, successful apply/destroy)

3. **Modern Services**
   - Kinesis Stream Consumer: ✅ Success (Valid config, successful apply/destroy)
   - AIOps Investigation Group: ❌ Failed (Invalid resource configuration)

Success Metrics:
- Configuration Syntax: 80% (4/5)
- Resource Support: 80% (4/5)
- Apply Success: 60% (3/5)

### Stage 4 Results

1. **Basic Resources**
   - S3 Bucket: ✅ Success (Valid config, successful apply/destroy)
   - Lambda Function: ✅ Success (Valid config, successful apply/destroy with IAM delay)

2. **Advanced Networking**
   - App Runner VPC Connector: ✅ Success (Valid config, successful apply/destroy)

3. **Modern Services**
   - Kinesis Stream Consumer: ✅ Success (Valid config, successful apply/destroy)
   - AIOps Investigation Group: ❌ Failed (IAM role assumption issues)

Success Metrics:
- Configuration Syntax: 100% (5/5)
- Resource Support: 100% (5/5)
- Apply Success: 80% (4/5)

```
tango-evaluation/
├── resources/              
│   ├── stage1/            # Stage 1 configurations
│   ├── stage2/            # Stage 2 configurations
│   ├── stage3/            # Stage 3 configurations
│   └── stage4/            # Stage 4 configurations
├── scripts/
│   └── validate.sh        # Validation script
└── results/
    ├── stage1/           # Stage 1 results and logs
    ├── stage2/           # Stage 2 results and logs
    ├── stage3/           # Stage 3 results and logs
    └── stage4/           # Stage 4 results and logs
```

## Evaluation Process

For each selected resource:
1. Generate examples using each implementation stage
2. Compare with official documentation (where available)
3. Run complete Terraform lifecycle validation
4. Document results and comparisons

## Metrics

1. **Generation Success**
   - Configuration syntax validity
   - Required attributes presence
   - Schema compatibility

2. **Terraform Lifecycle Validation**
   - `terraform init` - Provider initialization
   - `terraform validate` - Configuration validation
   - `terraform plan` - Execution plan verification
   - `terraform apply` - Resource creation attempt

3. **Code Quality Assessment**
   - Resource structure correctness
   - Required field coverage
   - Error handling
   - Documentation quality

4. **Resource Support**
   - Provider compatibility
   - Resource type availability
   - Schema version matching

## Key Findings

### Stage 1
1. **Code Generation**
   - Successfully generates valid HCL syntax
   - Includes all required fields
   - Proper structure and formatting
   - Appropriate use of placeholder values

2. **Resource Support**
   - Core services well supported (S3, Lambda)
   - Modern services partially supported (App Runner)
   - Newest services not yet available (AIOps, some Kinesis features)

3. **Common Issues**
   - Schema mismatches in configuration
   - Placeholder values causing expected failures
   - Resource type availability in provider

### Stage 2
1. **Code Generation**
   - Successfully generates valid HCL syntax
   - Includes all required fields
   - Proper structure and formatting
   - Appropriate use of variables and dependencies

2. **Resource Support**
   - Core services well supported (S3, Lambda)
   - Modern services partially supported (App Runner)
   - Newest services not yet available (AIOps, Kinesis features)

3. **Common Issues**
   - Resource type availability in provider
   - Schema mismatches in configuration
   - Provider version constraints
   - Service prerequisites documentation

### Stage 3
1. **Code Generation**
   - Successfully generates valid HCL syntax
   - Includes all required fields
   - Proper structure and formatting
   - Appropriate use of provider configurations

2. **Resource Support**
   - Core services well supported (Lambda)
   - Modern services mostly supported (App Runner, Kinesis)
   - Newest services not yet available (AIOps)

3. **Common Issues**
   - Access permissions for S3
   - Resource type availability
   - Schema mismatches in configuration
   - Provider version constraints

### Stage 4
1. **Code Generation**
   - Automated resource discovery and version detection
   - Smart processing with failure pattern learning
   - State persistence with DynamoDB integration
   - Enhanced storage with S3 and output truncation

2. **Resource Support**
   - Full provider integration with version awareness
   - Comprehensive resource tracking and state management
   - Automated cleanup with verification
   - Multi-phase validation process

3. **Common Issues**
   - IAM role propagation delays requiring timing adjustments
   - Service-specific permissions and role configurations
   - Resource dependencies and state synchronization
   - Output size management for large configurations
