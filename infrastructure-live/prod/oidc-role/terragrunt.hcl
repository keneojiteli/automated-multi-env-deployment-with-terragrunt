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
  environment       = "prod"
  github_repo       = "keneojiteli/automated-multi-env-deployment-with-terragrunt"
  oidc_provider_arn = dependency.oidc_provider.outputs.oidc_provider_arn

  permissions = [
    # S3 state bucket for prod (exact; no delete of bucket by default)
    {
      sid       = "ProdStateBucket"
      actions   = ["s3:GetObject","s3:PutObject","s3:ListBucket"]
      resources = ["arn:aws:s3:::terraform-state-*","arn:aws:s3:::terraform-state-*/*"]
    },

    # RunInstances only when request includes Environment=prod (prevents accidental untagged creations)
    {
      sid       = "RunInstancesWithEnvTag"
      actions   = ["ec2:RunInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "aws:RequestTag/Environment" = "prod"
        }
      }
    },

    # Allow destructive EC2 actions (Terminate) ONLY if the EC2 resource has both tags:
    #   Environment=prod  AND AllowDestroy=true
    {
      sid       = "ActOnTaggedEC2WithAllowDestroy"
      actions   = ["ec2:TerminateInstances","ec2:StopInstances","ec2:StartInstances","ec2:ModifyInstanceAttribute","ec2:DescribeInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "ec2:ResourceTag/Environment" = "prod"
          "ec2:ResourceTag/AllowDestroy" = "true"
        }
      }
    },

    # RDS destructive actions are allowed ONLY if RDS has both tags Environment=prod and AllowDestroy=true
    {
      sid       = "RDSActionsWithAllowDestroy"
      actions   = ["rds:DeleteDBInstance","rds:ModifyDBInstance","rds:RestoreDBInstanceFromS3","rds:DescribeDBInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "rds:ResourceTag/Environment" = "prod"
          "rds:ResourceTag/AllowDestroy" = "true"
        }
      }
    },
  ]
}
