aws_region         = "ap-south-1"
vpc_id             = "vpc-0056d809452f9f8ea" # Replace with your dev VPC ID
public_subnet_tags = ["Default Subnet* Batch-10"]

#k8s details
cluster_name        = "studentai-eks-dev"
kubernetes_version  = "1.30"
node_instance_types = ["t3.small"] # Smaller instances for cost savings
node_capacity_type  = "ON_DEMAND"  # ON_DEMAND instances for flexibility

# scaling configuration
node_desired_size = 3  # Start with 3 nodes for HA
node_max_size     = 10 # Can handle traffic spikes
node_min_size     = 2  # Always maintain 2 nodes minimum

public_access_cidrs = ["0.0.0.0/0"]
enable_irsa         = true

# helm chart details
nginx_ingress_chart_version = "4.13.1"
prometheus_chart_version    = "55.0.0"
grafana_chart_version       = "6.58.9"

grafana_port = 8080
