# Module Outputs for EKS Infrastructure

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC where the cluster is deployed"
  value       = var.vpc_id
}

output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = data.aws_subnets.private.ids
}

output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = data.aws_subnets.public.ids
}

# EKS Cluster Outputs
output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.studentai_cluster.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.studentai_cluster.arn
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane"
  value       = aws_eks_cluster.studentai_cluster.endpoint
}

output "cluster_security_group_id" {
  description = "Security group ID attached to the EKS cluster"
  value       = aws_eks_cluster.studentai_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = aws_eks_cluster.studentai_cluster.version
}

output "cluster_status" {
  description = "Status of the EKS cluster"
  value       = aws_eks_cluster.studentai_cluster.status
}

# IAM Outputs
output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_iam_role_name" {
  description = "IAM role name associated with EKS node group"
  value       = aws_iam_role.eks_node_role.name
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN associated with EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

# Node Group Outputs
output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.studentai_nodes.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.studentai_nodes.status
}

# OIDC Outputs
output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

# Cluster Autoscaler Output
output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

# Monitoring Outputs (if monitoring module is enabled)
output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  value       = try(kubernetes_namespace.monitoring.metadata[0].name, null)
}

output "studentai_namespace" {
  description = "Kubernetes namespace for StudentAI application"
  value       = try(kubernetes_namespace.studentai.metadata[0].name, null)
}

output "ingress_nginx_namespace" {
  description = "Kubernetes namespace for NGINX Ingress Controller"
  value       = try(kubernetes_namespace.ingress_nginx.metadata[0].name, null)
}

# Certificate Authority Data
output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.studentai_cluster.certificate_authority[0].data
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by EKS"
  value       = aws_eks_cluster.studentai_cluster.vpc_config[0].cluster_security_group_id
}

# LoadBalancer URLs for Monitoring Stack
output "grafana_loadbalancer_url" {
  description = "LoadBalancer URL for Grafana (when LoadBalancer service type is used)"
  value       = try("http://${data.kubernetes_service.grafana.status[0].load_balancer[0].ingress[0].hostname}:${var.grafana_port}", "LoadBalancer not ready or service not found")
}

output "prometheus_loadbalancer_url" {
  description = "LoadBalancer URL for Prometheus (when LoadBalancer service type is used)"
  value       = try("http://${data.kubernetes_service.prometheus.status[0].load_balancer[0].ingress[0].hostname}:9090", "LoadBalancer not ready or service not found")
}

# Service endpoints for kubectl port-forward commands
output "kubectl_port_forward_commands" {
  description = "kubectl commands to access services via port-forwarding"
  value = {
    grafana = "kubectl port-forward -n ${try(kubernetes_namespace.monitoring.metadata[0].name, "monitoring")} svc/grafana 3000:${var.grafana_port}"
    prometheus = "kubectl port-forward -n ${try(kubernetes_namespace.monitoring.metadata[0].name, "monitoring")} svc/prometheus-kube-prometheus-prometheus 9090:9090"
  }
}

# Service Details
output "monitoring_services" {
  description = "Details of monitoring services"
  value = {
    grafana = {
      service_name = "grafana"
      namespace    = try(kubernetes_namespace.monitoring.metadata[0].name, "monitoring")
      port         = var.grafana_port
      service_type = "LoadBalancer"
    }
    prometheus = {
      service_name = "prometheus-kube-prometheus-prometheus"
      namespace    = try(kubernetes_namespace.monitoring.metadata[0].name, "monitoring")
      port         = 9090
      service_type = "LoadBalancer"
    }
  }
}
