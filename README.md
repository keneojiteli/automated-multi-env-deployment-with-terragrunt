## Automated Multi-Environment Infrastructure Provisioning with Terraform, Terragrunt & CI/CD
## Project Overview
This project demonstrates a production-ready, multi-environment infrastructure automation setup using Terraform, Terragrunt, and GitHub Actions. It provisions AWS infrastructure across Development, Staging, and Production environments, using modular Terraform code, environment-based isolation, and secure CI/CD automation for provisioning and destroying infrastructure.

The goal is to achieve:

- Reusable, DRY (Don’t Repeat Yourself) Terraform configurations.
- Secure and consistent infrastructure management.
- Automated deployments with GitHub Actions.
- Multi-environment isolation using Terragrunt.



## Project structure
<!--```
.
├── .github/                         <-- GitHub configuration
│   └── workflows/                   <-- GitHub Actions workflows
│       └── terraform-create.yaml           <-- CI/CD pipeline to initialize, plan and apply terraform
        └── terraform-desroy.yaml           <-- CI/CD pipeline to destroy terraform resources
│
├── main.tf                <-- Root module (entry point)
├── provider.tf            <-- Provider & backend config
├── variables.tf           <-- Root-level input variables
├── output.tf              <-- Root-level outputs
├── README.md              <-- Project documentation
│
└── modules/
    ├── vpc/
    │   ├── main.tf        <-- Defines VPC resources (e.g., aws_vpc, subnets)
    │   ├── variables.tf   <-- Inputs specific to the VPC module
    │   └── output.tf      <-- Exports IDs (vpc_id, subnet_ids, etc.)
    │     
    ├── db/
    │   ├── main.tf        <-- Defines RDS resources (e.g., aws_db_subnet_group, aws_db_instance)
    │   ├── variables.tf   <-- Inputs specific to the RDS module
    │   └── output.tf      <-- Exports IDs
    │
    └── compute/
        ├── main.tf        <-- Defines EC2 resources etc.
        ├── variables.tf   <-- Inputs specific to the compute module
        └── output.tf      <-- Exports instance info, SG IDs, etc.
``` -->
```
multi-env-deployment/
├── infrastructure-modules/            # Terraform module code
│   ├── vpc/
│   ├── ec2/
│   └── rds/
└── infrastructure-live/               # Terragrunt layer
    ├── root.hcl                <-- global backend
    ├── dev/
    │   ├── terragrunt.hcl      <-- environment-level config
    │   ├── env.hcl             <-- actual values for resources per environment
    │   ├── vpc/
    │   │   └── terragrunt.hcl  <-- module-level config for vpc
    │   |└── compute/
    │   |    └── terragrunt.hcl  <-- module-level config for ec2 instance
    │   └── db/
    │       └── terragrunt.hcl    <-- module-level config for rds
    ├── staging/
    │   └── same structure as dev
    └── prod/
        └── same structure as dev
```
<!-- ```
.
├── live
│   ├── dev
│   │   ├── app
│   │   │   └── terragrunt.hcl
│   │   └── vpc
│   │       └── terragrunt.hcl
│   ├── stage
│   │   ├── app
│   │   │   └── terragrunt.hcl
│   │   └── vpc
│   │       └── terragrunt.hcl
│   └── prod
│       ├── app
│       │   └── terragrunt.hcl
│       └── vpc
│           └── terragrunt.hcl
└── modules
    ├── app
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── vpc
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
``` -->

Each environment has:
- Its own backend configuration (unique S3 key/state).
- Its own variable values and parameters.
- Separate pipelines and approval flow.

## Prerequisites
- Terraform & Terragrunt installed locally.
- AWS CLI configured with proper IAM access.
<!-- - GitHub Actions permissions for repository-level secrets:
    - AWS_ACCESS_KEY_ID
    - AWS_SECRET_ACCESS_KEY -->


## Solutions Solved
- Automated infrastructure provisioning across multiple environments.
- Centralized and version-controlled Infrastructure as Code (IaC).
- Secure state management via S3 backend + S3 native-lock feature.
- Environment isolation with Terragrunt’s layered structure.
- Integration of CI/CD for automated plan and apply operations.
- Validation and compliance checks via tflint, checkov, and terraform validate.

## Why I opted for Terragrunt?
While exploring multiple options for multi-environment automation (Terraform workspaces, backend configurations, and folder-based structures), I decided to use Terragrunt because it offers:
- Per-environment state management (no shared state conflicts).
- Automatic backend configuration generation.
- Dependency orchestration (VPC → Security Groups → EC2 → ECS).
- Dynamic input passing for each module.
- Cleaner folder-based structure and reusability.

## Pros
- DRY configuration (no repetitive backend or variable setup).
- Per-environment automation and isolation.
- Scales well for production setups and large teams.
- CI/CD friendly and extensible.

## Cons
- Slight learning curve (Terragrunt syntax and flow).
- Extra dependency (Terragrunt CLI).



<!-- ## CI/CD Automation with GitHub Actions
This project uses GitHub Actions to automate Terraform workflows for provisioning (apply) and destruction (destroy) in a consistent and secure manner. The workflows can be found in the `.github/workflows` directory in the root directory. The pipeline features include: configuring AWS credentials, setting up Terraform, Terraform initialization, linting, validation, and plan checks before apply and manual trigger for destruction (preventing accidental deletions).

## Best Practices followed
- I ensured each module focused on an AWS service (for example, VPC module contained everything required to build the VPC).
- I exposed only necessary outputs (especially the ones that will e required by other modules and passed to the root module, which is the connector).
- I parameterised my attributes and passed the values using variables (a`.tfvars` file can also be used to pass values).
- I added descriptions and defaults where needed to variables and outputs. -->





