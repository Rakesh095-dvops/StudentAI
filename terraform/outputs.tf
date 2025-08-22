# Outputs for EKS cluster
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

output "cluster_iam_role_name" {
  description = "IAM role name associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.name
}

output "cluster_iam_role_arn" {
  description = "IAM role ARN associated with EKS cluster"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data required to communicate with the cluster"
  value       = aws_eks_cluster.studentai_cluster.certificate_authority[0].data
}

output "cluster_primary_security_group_id" {
  description = "The cluster primary security group ID created by EKS"
  value       = aws_eks_cluster.studentai_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_version" {
  description = "The Kubernetes version for the EKS cluster"
  value       = aws_eks_cluster.studentai_cluster.version
}

output "cluster_platform_version" {
  description = "Platform version for the EKS cluster"
  value       = aws_eks_cluster.studentai_cluster.platform_version
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = aws_eks_cluster.studentai_cluster.status
}

# Outputs for EKS Node Group
output "node_groups" {
  description = "EKS node groups"
  value       = aws_eks_node_group.studentai_nodes.arn
}

output "node_group_iam_role_name" {
  description = "IAM role name associated with EKS node group"
  value       = aws_iam_role.eks_node_role.name
}

output "node_group_iam_role_arn" {
  description = "IAM role ARN associated with EKS node group"
  value       = aws_iam_role.eks_node_role.arn
}

output "node_group_status" {
  description = "Status of the EKS node group"
  value       = aws_eks_node_group.studentai_nodes.status
}

# Outputs for VPC information
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

# Outputs for OIDC provider
output "oidc_provider_arn" {
  description = "The ARN of the OIDC Provider"
  value       = aws_iam_openid_connect_provider.eks_oidc.arn
}

# Outputs for Cluster Autoscaler
output "cluster_autoscaler_role_arn" {
  description = "IAM role ARN for Cluster Autoscaler"
  value       = aws_iam_role.cluster_autoscaler.arn
}

# Outputs for Application
output "studentai_namespace" {
  description = "Kubernetes namespace for StudentAI application"
  value       = kubernetes_namespace.studentai.metadata[0].name
}

output "monitoring_namespace" {
  description = "Kubernetes namespace for monitoring stack"
  value       = kubernetes_namespace.monitoring.metadata[0].name
}

output "ingress_nginx_namespace" {
  description = "Kubernetes namespace for NGINX Ingress Controller"
  value       = kubernetes_namespace.ingress_nginx.metadata[0].name
}

# Outputs for Ingress
output "grafana_ingress_hostname" {
  description = "Hostname of the Grafana ingress"
  value       = var.domain_name != "" ? "https://grafana.${var.domain_name}" : "Use kubectl get ingress -n monitoring to get the load balancer hostname"
}

output "prometheus_ingress_hostname" {
  description = "Hostname of the Prometheus ingress"
  value       = var.domain_name != "" ? "https://prometheus.${var.domain_name}" : "Use kubectl get ingress -n monitoring to get the load balancer hostname"
}

# Outputs for accessing services locally
output "kubectl_config_command" {
  description = "Command to configure kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${var.cluster_name}"
}

output "grafana_port_forward_command" {
  description = "Command to access Grafana via port forwarding"
  value       = "kubectl port-forward -n monitoring svc/grafana 3000:80"
}

output "prometheus_port_forward_command" {
  description = "Command to access Prometheus via port forwarding"
  value       = "kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
}

output "nginx_ingress_external_ip_command" {
  description = "Command to get NGINX Ingress Controller external IP"
  value       = "kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}

# Output for getting ingress endpoints
output "get_ingress_endpoints_commands" {
  description = "Commands to get ingress endpoints"
  value = {
    nginx_ingress = "kubectl get svc -n ingress-nginx ingress-nginx-controller"
    grafana       = var.domain_name != "" ? "kubectl get ingress -n monitoring grafana-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'" : "kubectl port-forward -n monitoring svc/grafana 3000:80"
    prometheus    = var.domain_name != "" ? "kubectl get ingress -n monitoring prometheus-ingress -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'" : "kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090"
  }
}
