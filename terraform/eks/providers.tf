# Provider configurations for EKS deployment

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_id, "--region", var.aws_region]
  }
}

# Configure Helm provider
provider "helm" {
  # Use kubernetes configuration for Helm
  # This will use the same kubernetes configuration as above
}
