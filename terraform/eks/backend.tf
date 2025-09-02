# Backend configuration for Terraform state
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }

  # Uncomment and configure this block to store state in S3
  backend "s3" {
    bucket  = "studentai-tfstate-eks"
    key     = "eks/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
    #use_lockfile = true
  }
}
