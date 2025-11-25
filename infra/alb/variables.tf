variable "enable" {
  description = "Set to true to provision the AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "OIDC provider ARN exported by the EKS module"
  type        = string
}

variable "region" {
  description = "AWS region (used for tagging metadata)"
  type        = string
}

variable "vpc_id" {
  description = "VPC where the EKS cluster lives"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs that should be tagged for ALB usage"
  type        = list(string)
  default     = []
}

