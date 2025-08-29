# Main configuration to provision EKS cluster using modules

module "eks" {
  source = "../module"

  # VPC Configuration
  aws_region          = var.aws_region
  vpc_id              = var.vpc_id
  private_subnet_tags = var.private_subnet_tags
  public_subnet_tags  = var.public_subnet_tags

  # EKS Configuration
  cluster_name       = var.cluster_name
  kubernetes_version = var.kubernetes_version

  # Node Group Configuration
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type
  node_desired_size   = var.node_desired_size
  node_max_size       = var.node_max_size
  node_min_size       = var.node_min_size

  # Security Configuration
  public_access_cidrs = var.public_access_cidrs
  enable_irsa         = var.enable_irsa

  # Monitoring and Ingress Configuration
  nginx_ingress_chart_version = var.nginx_ingress_chart_version
  prometheus_chart_version    = var.prometheus_chart_version
  grafana_chart_version      = var.grafana_chart_version
  
  # Domain and SSL Configuration (optional)
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  grafana_port    = var.grafana_port
}
