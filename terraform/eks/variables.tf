# Variables for EKS provisioning

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "vpc_id" {
  description = "ID of the existing VPC"
  type        = string
}

variable "private_subnet_tags" {
  description = "Name tags to filter private subnets"
  type        = list(string)
  default     = ["*private*"]
}

variable "public_subnet_tags" {
  description = "Name tags to filter public subnets"
  type        = list(string)
  default     = ["*public*"]
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "studentai-eks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_types" {
  description = "EC2 instance types for the EKS managed node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_capacity_type" {
  description = "Capacity type for nodes (ON_DEMAND or SPOT)"
  type        = string
  default     = "ON_DEMAND"
}

variable "node_desired_size" {
  description = "Desired number of nodes"
  type        = number
  default     = 2
}

variable "node_max_size" {
  description = "Maximum number of nodes"
  type        = number
  default     = 4
}

variable "node_min_size" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access the Amazon EKS public API server endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_irsa" {
  description = "Enable IAM Roles for Service Accounts"
  type        = bool
  default     = true
}

variable "nginx_ingress_chart_version" {
  description = "NGINX Ingress Controller Helm chart version"
  type        = string
  default     = "4.13.1"
}

variable "prometheus_chart_version" {
  description = "Prometheus Helm chart version"
  type        = string
  default     = "55.0.0"
}

variable "grafana_chart_version" {
  description = "Grafana Helm chart version"
  type        = string
  default     = "6.58.9"
}

variable "domain_name" {
  description = "Domain name for ingress (optional)"
  type        = string
  default     = ""
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS (optional)"
  type        = string
  default     = ""
}

variable "grafana_port" {
  description = "Port for Grafana service (changed from 3000 to avoid conflict with StudentAI)"
  type        = number
  default     = 8080
}
