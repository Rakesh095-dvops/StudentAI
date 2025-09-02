# Outputs for EKS Infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = module.eks.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.eks.private_subnets
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.eks.public_subnets
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = module.eks.cluster_endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = module.eks.cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = module.eks.cluster_version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = module.eks.cluster_status
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = module.eks.cluster_certificate_authority_data
}

# IAM Outputs
output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = module.eks.cluster_iam_role_name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = module.eks.cluster_iam_role_arn
}

output "node_group_iam_role_name" {
  description = "IAM role name associated with EKS node group"
  value       = module.eks.node_group_iam_role_name
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN associated with EKS node group"
  value       = module.eks.node_group_iam_role_arn
}

# OIDC Outputs
output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = module.eks.oidc_provider_arn
}

output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = module.eks.cluster_autoscaler_role_arn
}

# Node Group Outputs
output "node_groups" {
  description = "EKS node groups"
  value       = module.eks.node_groups
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = module.eks.node_group_status
}

# Monitoring and Application Namespaces
output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  value       = module.eks.monitoring_namespace
}

output "studentai_namespace" {
  description = "Kubernetes namespace for StudentAI application"
  value       = module.eks.studentai_namespace
}

output "ingress_nginx_namespace" {
  description = "Kubernetes namespace for NGINX Ingress Controller"
  value       = module.eks.ingress_nginx_namespace
}

# kubectl config command
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
}

# Grafana and Prometheus access commands
output "grafana_port_forward_command" {
  description = "Command to access Grafana via port forwarding"
  value       = "kubectl port-forward -n monitoring svc/grafana 3000:${var.grafana_port}"
}

output "prometheus_port_forward_command" {
  description = "Command to access Prometheus via port forwarding"
  value       = "kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
}

# NGINX Ingress access command
output "nginx_ingress_external_ip_command" {
  description = "Command to get NGINX Ingress Controller external IP"
  value       = "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

# LoadBalancer URLs for Direct Access
output "grafana_loadbalancer_url" {
  description = "Direct LoadBalancer URL for Grafana"
  value       = module.eks.grafana_loadbalancer_url
}

output "prometheus_loadbalancer_url" {
  description = "Direct LoadBalancer URL for Prometheus"
  value       = module.eks.prometheus_loadbalancer_url
}

# Port Forward Commands
output "kubectl_port_forward_commands" {
  description = "kubectl port forwarding commands for local access"
  value       = module.eks.kubectl_port_forward_commands
}

# Service Details
output "monitoring_services" {
  description = "Details of monitoring services"
  value       = module.eks.monitoring_services
}

# Quick Access Summary
output "access_summary" {
  description = "Summary of how to access deployed services"
  value = {
    grafana = {
      loadbalancer_url = module.eks.grafana_loadbalancer_url
      port_forward     = module.eks.kubectl_port_forward_commands.grafana
      credentials      = "admin / admin123"
    }
    prometheus = {
      loadbalancer_url = module.eks.prometheus_loadbalancer_url
      port_forward     = module.eks.kubectl_port_forward_commands.prometheus
    }
    kubectl_setup = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
    output_files = {
      json = "output.json"
      txt  = "output.txt"
    }
  }
}
