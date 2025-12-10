include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "../../../infrastructure-modules//gha-oidc-role"
}

dependency "oidc_provider" {
  config_path = "../../oidc-provider"
}

inputs = {
  environment       = "staging"
  github_repo       = "keneojiteli/automated-multi-env-deployment-with-terragrunt"
  oidc_provider_arn = dependency.oidc_provider.outputs.oidc_provider_arn

  permissions = [
    # S3 state bucket for staging (exact)
    {
      sid       = "StagingStateBucket"
      actions   = ["s3:GetObject","s3:PutObject","s3:ListBucket","s3:DeleteObject"]
      resources = ["arn:aws:s3:::terraform-state-*","arn:aws:s3:::terraform-state-*/*"]
    },

    # Allow creating EC2 only when request includes Environment=staging tag
    {
      sid       = "RunInstancesWithEnvTag"
      actions   = ["ec2:RunInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "aws:RequestTag/Environment" = "staging"
        }
      }
    },

    # Allow management (including Terminate) only on EC2 with the matching tag
    {
      sid       = "ActOnTaggedEC2"
      actions   = ["ec2:TerminateInstances","ec2:StopInstances","ec2:StartInstances","ec2:ModifyInstanceAttribute","ec2:DescribeInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "ec2:ResourceTag/Environment" = "staging"
        }
      }
    },

    # RDS: allow create/modify/describe/delete for RDS resources that have Environment=staging tag
    {
      sid       = "RDSActionsOnTagged"
      actions   = ["rds:CreateDBInstance","rds:ModifyDBInstance","rds:DeleteDBInstance","rds:DescribeDBInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "rds:ResourceTag/Environment" = "staging"
        }
      }
    },
  ]
}
