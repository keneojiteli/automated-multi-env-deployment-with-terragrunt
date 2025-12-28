#!/bin/bash

# Terragrunt Helper Script for Local Development
# Usage: ./scripts/terragrunt-helper.sh <environment> <action> [resource]
#
# Examples:
#   ./scripts/terragrunt-helper.sh dev plan       # Plan all resources in dev
#   ./scripts/terragrunt-helper.sh dev apply      # Apply all resources in dev
#   ./scripts/terragrunt-helper.sh dev plan vpc   # Plan only VPC in dev

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
INFRASTRUCTURE_ROOT="$REPO_ROOT/infrastructure-live"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 <environment> <action> [resource]"
    echo ""
    echo "Environments: dev, staging, prod"
    echo "Actions: plan, apply, destroy, output, init"
    echo "Resources: vpc, compute, db, oidc-role (optional - if not specified, runs on all)"
    echo ""
    echo "Examples:"
    echo "  $0 dev plan           # Plan all resources in dev"
    echo "  $0 staging apply      # Apply all resources in staging"
    echo "  $0 prod plan vpc      # Plan only VPC in prod"
    echo "  $0 dev init           # Initialize all resources in dev"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check arguments
if [ $# -lt 2 ]; then
    log_error "Insufficient arguments"
    usage
    exit 1
fi

ENVIRONMENT=$1
ACTION=$2
RESOURCE=${3:-""}

# Validate environment
case $ENVIRONMENT in
    dev|staging|prod)
        ;;
    *)
        log_error "Invalid environment: $ENVIRONMENT"
        usage
        exit 1
        ;;
esac

# Validate action
case $ACTION in
    plan|apply|destroy|output|init)
        ;;
    *)
        log_error "Invalid action: $ACTION"
        usage
        exit 1
        ;;
esac

# Set working directory
WORK_DIR="$INFRASTRUCTURE_ROOT/$ENVIRONMENT"

if [ ! -d "$WORK_DIR" ]; then
    log_error "Environment directory does not exist: $WORK_DIR"
    exit 1
fi

# Check if terragrunt is installed
if ! command -v terragrunt &> /dev/null; then
    log_error "Terragrunt is not installed or not in PATH"
    echo "Please install terragrunt: https://terragrunt.gruntwork.io/docs/getting-started/install/"
    exit 1
fi

# Pre-flight checks
log_info "Running pre-flight checks..."

# Check AWS credentials
if ! aws sts get-caller-identity &> /dev/null; then
    log_error "AWS credentials not configured"
    log_info "Please configure AWS credentials using one of these methods:"
    log_info "  - aws configure"
    log_info "  - Set environment variables: AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY"
    log_info "  - Use IAM roles or instance profiles"
    exit 1
fi

# Check if state lock table exists
if ! aws dynamodb describe-table --table-name terraform-state-lock-table --region us-east-1 &> /dev/null; then
    log_warning "State lock table does not exist"
    log_info "Creating state lock table..."

    cd "$INFRASTRUCTURE_ROOT/state-lock"
    terragrunt apply -auto-approve

    if [ $? -eq 0 ]; then
        log_success "State lock table created successfully"
    else
        log_error "Failed to create state lock table"
        exit 1
    fi
fi

# Change to environment directory
cd "$WORK_DIR"
log_info "Working in: $WORK_DIR"

# Build terragrunt command
if [ -n "$RESOURCE" ]; then
    # Single resource
    if [ ! -d "$RESOURCE" ]; then
        log_error "Resource directory does not exist: $RESOURCE"
        exit 1
    fi

    log_info "Running $ACTION on $RESOURCE in $ENVIRONMENT environment"
    cd "$RESOURCE"

    case $ACTION in
        plan)
            terragrunt plan
            ;;
        apply)
            terragrunt apply
            ;;
        destroy)
            terragrunt destroy
            ;;
        output)
            terragrunt output
            ;;
        init)
            terragrunt init
            ;;
    esac
else
    # All resources
    log_info "Running $ACTION on all resources in $ENVIRONMENT environment"

    case $ACTION in
        plan)
            terragrunt run-all plan --terragrunt-non-interactive
            ;;
        apply)
            terragrunt run-all apply --terragrunt-non-interactive
            ;;
        destroy)
            log_warning "This will DESTROY all resources in $ENVIRONMENT environment!"
            echo "Type 'yes' to continue: "
            read confirmation
            if [ "$confirmation" = "yes" ]; then
                terragrunt run-all destroy --terragrunt-non-interactive
            else
                log_info "Operation cancelled"
                exit 0
            fi
            ;;
        output)
            terragrunt run-all output
            ;;
        init)
            terragrunt run-all init --terragrunt-non-interactive
            ;;
    esac
fi

if [ $? -eq 0 ]; then
    log_success "Operation completed successfully!"
else
    log_error "Operation failed!"
    exit 1
fi