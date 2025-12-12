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
  environment = "dev"
  github_repo = "keneojiteli/automated-multi-env-deployment-with-terragrunt"
  oidc_provider_arn = dependency.oidc_provider.outputs.oidc_provider_arn
  

  permissions = [
    # S3
    {
      sid = "StateBucket"
      actions = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetBucketLocation",
        "s3:GetBucketPolicy",
        "s3:GetBucketVersioning",
        "s3:GetEncryptionConfiguration",
        "s3:PutEncryptionConfiguration",
        "s3:GetBucketPublicAccessBlock"
      ]
      # resources = ["arn:aws:s3:::terraform-state-*","arn:aws:s3:::terraform-state-*/*"]
      resources = [
        "arn:aws:s3:::terraform-state-bucket-101325",
        "arn:aws:s3:::terraform-state-bucket-101325/*"
        ]
    },

    # create EC2 only when request includes Env tag
    {
      sid = "RunInstancesWithEnvTag"
      actions = ["ec2:RunInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "aws:RequestTag/Environment" = "dev"
        }
      }
    },

    # Allow management actions only on EC2 with the matching tag
    {
      sid = "ActOnTaggedEC2"
      actions = ["ec2:TerminateInstances","ec2:StopInstances","ec2:StartInstances","ec2:ModifyInstanceAttribute"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "ec2:ResourceTag/Environment" = "dev"
        }
      }
    },

    # RDS limited to resources with tag
    {
      sid = "RDSActionsOnTagged"
      actions = ["rds:CreateDBInstance","rds:ModifyDBInstance","rds:DescribeDBInstances"]
      resources = ["*"]
      condition = {
        StringEquals = {
          "rds:ResourceTag/Environment" = "dev"
        }
      }
    }
  ]
}