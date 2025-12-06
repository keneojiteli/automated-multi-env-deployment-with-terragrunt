variable "oidc_provider_arn" {
  type = string
  description = "The ARN of the AWS OIDC provider created in the oidc-provider module"
}

variable "environment" {}
variable "github_repo" {}
variable "permissions" {
  type = list(object({
    sid     = string
    actions = list(string)
    resources = list(string)
  }))
}