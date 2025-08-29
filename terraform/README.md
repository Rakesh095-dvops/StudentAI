# EKS Infrastructure - Modular Terraform Architecture

This directory contains a modular Terraform configuration for deploying Amazon EKS (Elastic Kubernetes Service) infrastructure with monitoring and ingress capabilities.

## 🏗️ Architecture Overview

The configuration is split into two main directories:
- **`module/`**: Contains the reusable building blocks for the EKS cluster, including VPC, IAM, EKS components, monitoring, and ingress.
- **`eks/`**: Contains the root module responsible for deploying the EKS infrastructure by calling the child modules.

### Directory Structure
```
terraform/
├── eks/                    # EKS provisioning files (Root Module)
│   ├── backend.tf         # Provider configuration and S3 backend
│   ├── main.tf           # Main module call to provision EKS
│   ├── variables.tf      # Input variables for EKS deployment
│   ├── outputs.tf        # Output values from EKS deployment
│   ├── providers.tf      # Provider configurations for the root module
│   └── terraform.tfvars  # Variable values for a specific deployment
│
└── module/                # EKS building blocks (Child Module)
    ├── main.tf           # Main provider configuration for the module
    ├── variables.tf      # All module variables
    ├── outputs.tf        # All module outputs
    ├── vpc.tf           # VPC and networking configuration
    ├── iam.tf           # IAM roles and policies
    ├── eks.tf           # EKS cluster and node group
    ├── oidc.tf          # OpenID Connect provider for IRSA
    ├── monitoring.tf    # Prometheus and Grafana monitoring
    ├── ingress.tf       # NGINX Ingress Controller and Cluster Autoscaler
    └── application.tf   # Application namespaces and configurations
```

### Key Benefits
- **Modularity**: Each component is in its own file, making it easy to understand, maintain, and reuse.
- **Separation of Concerns**: Infrastructure components are separated by function, leading to clean dependency management and easier debugging.
- **Scalability**: The structure allows for easy addition of new components and environment-specific configurations.
- **Best Practices**: Follows standard Terraform module patterns with clear variable/output definitions and comprehensive documentation.

## 🚀 Deployment Guide

### Prerequisites
- AWS CLI configured with appropriate permissions.
- Terraform >= 1.0 installed.
- `kubectl` installed for cluster interaction.
- An existing VPC with public subnets.

### Step 1: Navigate to the Deployment Directory
All deployment commands should be run from the `eks` directory.
```bash
cd terraform/eks
```

### Step 2: Configure Deployment Variables
Edit `terraform.tfvars` with your specific values.
```hcl
aws_region         = "ap-south-1"
vpc_id             = "vpc-xxxxxxxxx"  # Replace with your VPC ID
public_subnet_tags = ["your-public-subnet-tag-pattern"] # e.g., "Name=studentai-public-subnet-*"
cluster_name       = "studentai-eks-dev"
```

### Step 3: Configure S3 Backend (Optional, but Recommended)
For production use, uncomment and configure the S3 backend in `backend.tf` to securely store your Terraform state.
```hcl
# backend "s3" {
#   bucket         = "your-terraform-state-bucket"
#   key            = "eks/terraform.tfstate"
#   region         = "ap-south-1"
#   encrypt        = true
#   dynamodb_table = "terraform-state-locks"
# }
```

### Step 4: Deploy the Infrastructure
```bash
# Initialize Terraform (downloads providers and modules)
terraform init

# Plan the deployment (shows what will be created)
terraform plan

# Apply the configuration to create the resources
terraform apply -auto-approve
```

### Step 5: Configure kubectl
After the apply is complete, configure `kubectl` to connect to your new EKS cluster.
```bash
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks-dev
```

### Step 6: Verify the Deployment
Check that the nodes have joined the cluster and that core pods are running.
```bash
kubectl get nodes
kubectl get pods --all-namespaces
```

## 📊 Accessing Services

### Grafana Dashboard
```bash
# Forward the Grafana service port to your local machine
kubectl port-forward -n monitoring svc/grafana 3000:8080

# Access at: http://localhost:3000
# Default credentials: admin/admin123
```

### Prometheus Metrics
```bash
# Forward the Prometheus service port
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090

# Access at: http://localhost:9090
```

### NGINX Ingress
Check the external IP or hostname assigned to the NGINX Ingress controller.
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

## � Configuration and Customization

### EKS Configuration
- **Kubernetes Version**: Default `1.30` (configurable in `terraform.tfvars`).
- **Node Instance Types**: Default `t3.small`.
- **Scaling**: Min 2, Desired 3, Max 10 nodes.

### Adding Custom Applications
Add your application configurations to `module/application.tf` or create new module files for larger components.

## 🧹 Cleanup
To destroy all the infrastructure created by this configuration:
```bash
cd terraform/eks
terraform destroy -auto-approve
```

## 🚨 Troubleshooting

### Common Issues
1.  **Permission Denied**: Ensure your AWS CLI credentials have the necessary IAM permissions for EKS, EC2, IAM, and VPC.
2.  **Node Group Fails**: Verify that the subnets have internet connectivity (via an Internet Gateway) and that the security group rules are correct.
3.  **Pods Pending**: Check for insufficient resources (`kubectl describe node`) or issues with Persistent Volume Claims (PVCs).

### Debug Commands
```bash
# Get detailed information about the cluster
kubectl cluster-info

# Describe a node to check its status and resource allocation
kubectl describe nodes

# Check the logs for a specific pod
kubectl logs -n <namespace> <pod-name>
```

## 📚 Additional Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Prometheus Operator](https://prometheus-operator.dev/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
