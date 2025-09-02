# Provider configurations for EKS deployment

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Configure Kubernetes provider
provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "")
  cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
  token                  = try(data.aws_eks_cluster_auth.cluster.token, "")
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = try(module.eks.cluster_endpoint, "")
    cluster_ca_certificate = try(base64decode(module.eks.cluster_certificate_authority_data), "")
    token                  = try(data.aws_eks_cluster_auth.cluster.token, "")
  }
}

data "aws_eks_cluster_auth" "cluster" {
  name = try(module.eks.cluster_id, "")
}
