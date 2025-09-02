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
  grafana_chart_version       = var.grafana_chart_version

  # Domain and SSL Configuration (optional)
  domain_name     = var.domain_name
  certificate_arn = var.certificate_arn
  grafana_port    = var.grafana_port
}

# Generate output files with deployment information
/* resource "local_file" "deployment_output_json" {
  content = jsonencode({
    cluster_info = {
      cluster_name     = module.eks.cluster_id
      cluster_endpoint = module.eks.cluster_endpoint
      cluster_status   = module.eks.cluster_status
      cluster_version  = module.eks.cluster_version
    }
    
    monitoring_services = {
      grafana = {
        loadbalancer_url       = module.eks.grafana_loadbalancer_url
        port_forward_command   = module.eks.kubectl_port_forward_commands.grafana
        admin_password        = "admin123"
        service_details       = module.eks.monitoring_services.grafana
      }
      prometheus = {
        loadbalancer_url       = module.eks.prometheus_loadbalancer_url
        port_forward_command   = module.eks.kubectl_port_forward_commands.prometheus
        service_details       = module.eks.monitoring_services.prometheus
      }
    }
    
    kubectl_access = {
      configure_kubectl = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}"
      check_nodes      = "kubectl get nodes"
      check_services   = "kubectl get svc -n ${module.eks.monitoring_namespace}"
    }
    
    namespaces = {
      monitoring     = module.eks.monitoring_namespace
      studentai      = module.eks.studentai_namespace
      ingress_nginx  = module.eks.ingress_nginx_namespace
    }
    
    generated_at = formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())
  })
  
  filename = "${path.module}/output.json"
}
 */
resource "local_file" "deployment_output_txt" {
  content = <<-EOT
# EKS Cluster Deployment Summary
Generated at: ${formatdate("YYYY-MM-DD hh:mm:ss ZZZ", timestamp())}

## Cluster Information
- Cluster Name: ${module.eks.cluster_id}
- Cluster Endpoint: ${module.eks.cluster_endpoint}
- Cluster Status: ${module.eks.cluster_status}
- Kubernetes Version: ${module.eks.cluster_version}

## Configure kubectl Access
aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_id}

## Monitoring Services

### Grafana
- LoadBalancer URL: ${module.eks.grafana_loadbalancer_url}
- Port Forward Command: ${module.eks.kubectl_port_forward_commands.grafana}
- Admin Username: admin
- Admin Password: admin123
- Access via browser: Open the LoadBalancer URL or use port forwarding and go to http://localhost:3000

### Prometheus
- LoadBalancer URL: ${module.eks.prometheus_loadbalancer_url}
- Port Forward Command: ${module.eks.kubectl_port_forward_commands.prometheus}
- Access via browser: Open the LoadBalancer URL or use port forwarding and go to http://localhost:9090

## Useful kubectl Commands
- Check cluster nodes: kubectl get nodes
- Check monitoring services: kubectl get svc -n ${module.eks.monitoring_namespace}
- Check all pods in monitoring: kubectl get pods -n ${module.eks.monitoring_namespace}
- Check LoadBalancer status: kubectl get svc -n ${module.eks.monitoring_namespace} -o wide

## Namespaces
- Monitoring: ${module.eks.monitoring_namespace}
- StudentAI: ${module.eks.studentai_namespace}
- Ingress NGINX: ${module.eks.ingress_nginx_namespace}

## Note
It may take a few minutes for the LoadBalancer URLs to become available after deployment.
You can check the status with: kubectl get svc -n monitoring
EOT

  filename = "${path.module}/output.txt"
}
