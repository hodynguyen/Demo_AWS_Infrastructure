variable "vpc_id" {
  description = "VPC ID for EKS"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for EKS nodes & control plane"
  type        = list(string)
}
