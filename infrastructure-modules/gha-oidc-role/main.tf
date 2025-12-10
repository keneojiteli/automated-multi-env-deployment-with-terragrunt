# tells terraform to expect remote state configuration
terraform {
  backend "s3" {}
}

resource "aws_iam_role" "this" {
  name               = "gh-actions-${var.environment}-role"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

data "aws_iam_policy_document" "trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]   # ensure to use ARN, not URL
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = [
        "repo:${var.github_repo}:environment:${var.environment}"
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "combined" {
  dynamic "statement" {
    for_each = var.permissions
    content {
      sid       = statement.value.sid
      actions   = statement.value.actions
      resources = statement.value.resources
      effect    = "Allow"
    }
  }
}

resource "aws_iam_policy" "this" {
  name   = "gh-actions-${var.environment}-policy"
  policy = data.aws_iam_policy_document.combined.json
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
