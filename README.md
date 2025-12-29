# Multi-Environment Infrastructure Deployment with Terragrunt

A comprehensive Infrastructure as Code (IaC) solution using **Terragrunt** and **GitHub Actions** for automated multi-environment deployment across Dev, Staging, and Production environments.

## 🎯 **Project Overview**

This project demonstrates a production-ready approach to Infrastructure as Code using Terragrunt for DRY (Don't Repeat Yourself) configurations and GitHub Actions for automated CI/CD. The solution provisions AWS infrastructure (VPC, EC2, RDS) across multiple environments with proper state management, dependency resolution, and rollback capabilities.

## 🚀 **Why Terragrunt?**

### **Problems This Project Solves**

1. **Code Duplication**: Traditional Terraform requires copying configurations for each environment
2. **Manual Dependency Management**: Resources need to be deployed in correct order manually
3. **Individual Resource Deployment**: Having to `cd` into each resource directory individually
4. **State Management Complexity**: Managing remote state and locking across multiple environments
5. **Deployment Coordination**: Ensuring proper deployment order and error handling in CI/CD
6. **Environment Isolation**: Preventing cross-environment state pollution
7. **Rollback Challenges**: Lack of automated rollback to last known good state

### **Why Terragrunt Over Pure Terraform?**

- **DRY Principle**: Single module definitions, multiple environment configurations
- **Dependency Management**: Automatic resource dependency resolution and ordering
- **Bulk Operations**: Deploy/plan all resources with `run-all` commands
- **Configuration Inheritance**: Shared configurations with environment-specific overrides
- **Advanced Backend Management**: Automated backend generation and state isolation
- **Mock Outputs**: Ability to plan without all dependencies being deployed

## 📁 **Project Structure**

```
├── .github/
│   └── workflows/
│       ├── deploy.yml              # Main deployment workflow
│       ├── rollback.yml            # Rollback workflow
│       └── infra-plan.yaml         # Legacy plan workflow (deprecated)
├── infrastructure-modules/         # Reusable Terraform modules
│   ├── vpc/                       # VPC module
│   ├── compute/                   # EC2 module
│   ├── db/                        # RDS module
│   └── state-lock/                # DynamoDB state locking module
├── infrastructure-live/           # Terragrunt live configurations
│   ├── root.hcl                   # Global configuration
│   ├── state-lock/                # Bootstrap state locking infrastructure
│   ├── dev/                       # Development environment
│   │   ├── env.hcl               # Dev-specific variables
│   │   ├── terragrunt.hcl        # Dev environment config
│   │   ├── vpc/terragrunt.hcl    # VPC configuration
│   │   ├── compute/terragrunt.hcl # EC2 configuration
│   │   └── db/terragrunt.hcl     # RDS configuration
│   ├── staging/                   # Staging environment (same structure)
│   └── prod/                      # Production environment (same structure)
├── scripts/
│   └── terragrunt-helper.sh       # Local development helper script
└── README.md
```

## 🔧 **Issues Identified & Solutions Implemented**

### **Original Issues Found**

1. **❌ Missing State Locking**: Used `use_lockfile = true` instead of DynamoDB
2. **❌ No Dependency Management**: Resources couldn't determine deployment order
3. **❌ Manual Resource Deployment**: Required `cd` into each directory individually
4. **❌ Pipeline Used Single Resources**: GitHub Actions used `terragrunt run --` instead of `run-all`
5. **❌ No Mock Outputs**: Couldn't plan resources without dependencies deployed
6. **❌ Missing Rollback Mechanism**: No automated way to revert to previous versions
7. **❌ Limited Local Development Tools**: No helper scripts for bulk operations

### **✅ Solutions Implemented**

#### **1. Enhanced State Management**
- **Before**: `use_lockfile = true` (S3 native locking)
- **After**: DynamoDB table with `terraform-state-lock-table`
- **Why**: More reliable concurrent access, atomic operations, better error handling

```hcl
# root.hcl - FIXED
remote_state {
  backend = "s3"
  config = {
    bucket         = "terraform-state-bucket-101325"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = local.region
    encrypt        = true
    dynamodb_table = "terraform-state-lock-table"  # ✅ Added
  }
  generate = {  # ✅ Added
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

#### **2. Dependency Management & Mock Outputs**
- **Before**: Basic dependency blocks without mock outputs
- **After**: Enhanced dependencies with mock outputs and validation

```hcl
# compute/terragrunt.hcl - ENHANCED
dependency "vpc" {
  config_path = "../vpc"
  mock_outputs = {  # ✅ Added
    pub_subnet_id = "subnet-000000"
    vpc_sg        = "sg-000000"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]  # ✅ Added
  mock_outputs_merge_with_state           = true  # ✅ Added
}
```

#### **3. Bulk Operations Support**
- **Before**: Individual resource deployment only
- **After**: Full `run-all` support with helper scripts

```bash
# NEW: Helper script for bulk operations
./scripts/terragrunt-helper.sh dev plan     # Plan all resources
./scripts/terragrunt-helper.sh dev apply    # Apply all resources
```

#### **4. Enhanced GitHub Actions Workflows**

**New `deploy.yml` Workflow Features:**
- ✅ Matrix strategy for parallel environment deployment
- ✅ Smart change detection (auto-deploys based on file changes)
- ✅ `terragrunt run-all` commands instead of single resource runs
- ✅ Artifact management for plans and rollbacks
- ✅ Automatic state lock table bootstrapping

**New `rollback.yml` Workflow Features:**
- ✅ Last known good deployment tracking
- ✅ Manual approval process
- ✅ Commit-based rollback capability
- ✅ Deployment metadata storage in S3

#### **5. State Lock Infrastructure Module**
```hcl
# NEW: infrastructure-modules/state-lock/
# Creates DynamoDB table for state locking
# Uses local backend to avoid circular dependency
```

#### **6. Local Development Enhancements**
- ✅ Pre-flight checks (AWS credentials, state lock table)
- ✅ Colored output and user-friendly interface
- ✅ Both bulk and targeted operations support
- ✅ Automatic error handling and validation

## 🏗️ **Architecture**

The project creates the following infrastructure across three environments:

- **VPC**: Isolated network with public/private subnets
- **EC2**: Compute instances in public subnets
- **RDS**: PostgreSQL databases in private subnets
- **Security Groups**: Proper network access controls
- **State Management**: S3 backend + DynamoDB locking

### **Environment Specifications**

| Environment | VPC CIDR      | Instance Type | DB Instance   |
|-------------|---------------|---------------|---------------|
| Dev         | 10.0.0.0/16   | t2.micro     | db.t4g.micro  |
| Staging     | 10.1.0.0/16   | t3.small     | db.t4g.small  |
| Production  | 10.2.0.0/16   | t3.medium    | db.t4g.medium |

## 🚀 **Getting Started**

### **Prerequisites**

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with credentials
3. **Terragrunt** v0.92.1+ installed
4. **Terraform** v1.8.2+ installed
5. **Git** for version control

### **AWS Permissions Required**

Your AWS credentials need permissions for:
- EC2 (VPC, subnets, instances, security groups)
- RDS (database instances, subnet groups)
- S3 (state bucket access)
- DynamoDB (state lock table)
- IAM (if using OIDC for GitHub Actions)

## 📋 **Setup Instructions**

### **1. Clone Repository**
```bash
git clone https://github.com/keneojiteli/multi-env-deployment-with-terragrunt-infracodebase.git
cd multi-env-deployment-with-terragrunt-infracodebase
```

### **2. Configure AWS Credentials**

**Option A: AWS CLI**
```bash
aws configure
```

**Option B: Environment Variables**
```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### **3. Verify S3 Bucket Exists**
```bash
aws s3 ls s3://terraform-state-bucket-101325
```
If the bucket doesn't exist, create it:
```bash
aws s3 mb s3://terraform-state-bucket-101325 --region us-east-1
```

### **4. Bootstrap State Locking (First Time Only)**
```bash
cd infrastructure-live/state-lock
terragrunt apply
```

### **5. Deploy Environment**

**Option A: Using Helper Script (Recommended)**
```bash
# Make script executable
chmod +x scripts/terragrunt-helper.sh

# Deploy dev environment
./scripts/terragrunt-helper.sh dev init
./scripts/terragrunt-helper.sh dev plan
./scripts/terragrunt-helper.sh dev apply

# Deploy staging
./scripts/terragrunt-helper.sh staging apply

# Deploy production
./scripts/terragrunt-helper.sh prod apply
```

**Option B: Manual Terragrunt Commands**
```bash
cd infrastructure-live/dev
terragrunt run-all init
terragrunt run-all plan
terragrunt run-all apply
```

## 🔄 **CI/CD Pipeline Usage**

### **Automatic Deployment**
- **Push to `main`**: Automatically deploys to environments based on changed files
- **Module changes**: Deploys to all environments (dev → staging → prod)
- **Environment-specific changes**: Deploys only to affected environment

### **Manual Deployment**
Use GitHub Actions workflow dispatch:
1. Go to Actions tab in GitHub
2. Select "Multi-Environment Infrastructure Deploy"
3. Click "Run workflow"
4. Choose environment and action (plan/apply/destroy)

### **Rollback Process**
1. Go to Actions tab in GitHub
2. Select "Rollback Infrastructure"
3. Click "Run workflow"
4. Choose environment and optionally specify target commit
5. Approve the rollback when prompted

## 🧪 **Testing & Validation**

### **Local Testing**
```bash
# Test individual resource
./scripts/terragrunt-helper.sh dev plan vpc

# Test all resources
./scripts/terragrunt-helper.sh dev plan

# Validate configuration
./scripts/terragrunt-helper.sh dev validate
```

### **Dependency Testing**
```bash
# Test with mock outputs (no dependencies deployed)
cd infrastructure-live/dev/compute
terragrunt plan  # Should work with mock outputs

# Test real dependencies
cd ../vpc
terragrunt apply
cd ../compute
terragrunt plan  # Should use real VPC outputs
```

### **Pipeline Testing**
1. Create a feature branch
2. Make changes to infrastructure
3. Push branch and create PR
4. Verify plan runs successfully
5. Merge to main for deployment

## 🔧 **Troubleshooting**

### **Common Issues**

**1. State Lock Table Missing**
```
Error: Error acquiring the state lock
```
**Solution**: Run the bootstrap command:
```bash
cd infrastructure-live/state-lock
terragrunt apply
```

**2. AWS Credentials Not Found**
```
Error: Unable to locate credentials
```
**Solution**: Configure AWS credentials or verify environment variables

**3. Dependency Failures**
```
Error: dependency.vpc.outputs.vpc_id is not available
```
**Solution**: Deploy VPC first or check mock outputs configuration

**4. S3 Bucket Access Denied**
```
Error: AccessDenied: Access Denied
```
**Solution**: Verify S3 bucket exists and AWS credentials have proper permissions

### **Debugging Commands**
```bash
# Check Terragrunt configuration
terragrunt terragrunt-info

# Debug dependency graph
terragrunt graph-dependencies

# Validate all configurations
terragrunt run-all validate

# Show planned changes without applying
terragrunt run-all plan
```

## ❓ **FAQ: DynamoDB vs S3 Native Locking**

**Q: Why was DynamoDB state locking added when S3 has native locking?**

**A: Here's the comparison:**

### **S3 Native Locking (`use_lockfile = true`)**
- ✅ Simple setup, no additional resources
- ❌ Race conditions possible with concurrent access
- ❌ Limited error handling and retry mechanisms
- ❌ Less reliable for team environments and CI/CD

### **DynamoDB Locking (`dynamodb_table`)**
- ✅ Atomic operations prevent race conditions
- ✅ Industry standard recommended by HashiCorp/Gruntwork
- ✅ Better error handling and lock timeout management
- ✅ Supports multiple concurrent readers, single writer
- ✅ More reliable for production environments
- ❌ Additional AWS resource (minimal cost: ~$2.50/month)

**If you prefer S3 native locking**, you can revert by changing `root.hcl`:
```hcl
remote_state {
  config = {
    # Remove: dynamodb_table = "terraform-state-lock-table"
    # Add: use_lockfile = true
  }
}
```

## 🔐 **Security Considerations**

1. **State Encryption**: All state files are encrypted in S3
2. **Credential Management**: Use IAM roles, avoid hardcoded credentials
3. **Network Security**: RDS in private subnets, proper security groups
4. **Access Control**: Environment-specific IAM roles for GitHub Actions
5. **Secret Management**: Use GitHub Secrets for sensitive data

## 📊 **Monitoring & Maintenance**

### **State Management**
- Monitor S3 bucket size and costs
- Regularly review state lock table for orphaned locks
- Backup state files before major changes

### **Cost Optimization**
- Use appropriate instance types per environment
- Implement auto-shutdown for dev/staging environments
- Monitor AWS costs using Cost Explorer

### **Updates & Maintenance**
- Regularly update Terraform and Terragrunt versions
- Review and update module versions
- Monitor AWS service updates and deprecations

## 🤝 **Contributing**

1. Fork the repository
2. Create a feature branch
3. Make changes and test locally
4. Submit a pull request
5. Ensure CI/CD pipeline passes

## 📄 **License**

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 **Support**

For issues and questions:
1. Check the troubleshooting section
2. Review GitHub Issues
3. Create a new issue with detailed information
4. Include error logs and configuration details

---

**Built with ❤️ using Terragrunt, Terraform, and GitHub Actions**

