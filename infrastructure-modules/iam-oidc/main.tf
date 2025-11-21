# 1. OIDC provider
# 2. Trust policy documents (dev/staging/prod)
# 3. IAM roles (dev/staging/prod)
# 4. Permission policies (dev/staging/prod)
# 5. Role policy attachments (dev/staging/prod)

locals {
  role_name = "${var.environment}-github-oidc-role"
}


# OIDC PROVIDER (Created once per AWS account)
# Terragrunt will try to apply this in each env, but AWS sees it's identical and reuses it

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://${var.oidc_provider}"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}


# IAM ROLE TRUST POLICY - Restricted to my repo + environment

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:sub"
      values   = ["repo:${var.github_repo}:ref:refs/heads/${var.environment}"]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider}:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "github_role" {
  name               = local.role_name
  assume_role_policy = data.aws_iam_policy_document.trust.json
}


# PERMISSIONS POLICY - Attach the permissions needed for VPC, EC2, RDS + S3 backend


data "aws_iam_policy_document" "permissions" {
  statement {
    sid       = "S3State"
    actions   = ["s3:*"]
    resources = ["arn:aws:s3:::terraform-state-bucket-*", "arn:aws:s3:::terraform-state-bucket-*/*"]
  }

  statement {
    sid = "EC2"
    actions = [
      "ec2:*"
    ]
    resources = ["*"]
  }

  statement {
    sid = "VPC"
    actions = [
      "ec2:CreateVpc",
      "ec2:ModifyVpcAttribute",
      "ec2:DeleteVpc",
      "ec2:CreateSubnet",
      "ec2:DeleteSubnet",
      "ec2:CreateInternetGateway",
      "ec2:AttachInternetGateway",
      "ec2:DeleteInternetGateway",
      "ec2:CreateRoute",
      "ec2:CreateRouteTable",
      "ec2:AssociateRouteTable"
    ]
    resources = ["*"]
  }

  statement {
    sid = "RDS"
    actions = [
      "rds:*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "permissions" {
  name   = "${local.role_name}-policy"
  policy = data.aws_iam_policy_document.permissions.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.github_role.name
  policy_arn = aws_iam_policy.permissions.arn
}

output "role_arn" {
  value = aws_iam_role.github_role.arn
}