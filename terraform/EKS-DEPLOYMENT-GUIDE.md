# EKS Creation Using Terraform with GitHub Actions

This repository contains GitHub Actions workflows for creating and managing an EKS cluster using Terraform.

## Workflows Overview

### 1. EKS Deploy Workflow (`eks-deploy.yml`)
- **Purpose**: Complete EKS cluster creation, validation, and destruction
- **Triggers**: 
  - Push to `main` or `feature/terraform` branches
  - Pull requests to `main`
  - Manual workflow dispatch
- **Jobs**:
  - `terraform-validate`: Validates and plans Terraform
  - `terraform-apply`: Creates EKS cluster (only on main branch or manual trigger)
  - `terraform-destroy`: Destroys EKS cluster (manual trigger only)
  - `notify`: Sends deployment status notifications

### 2. Terraform Validate Workflow (`validate-terraform.yml`)
- **Purpose**: Quick validation and planning for feature branches
- **Triggers**: Push to `feature/terraform` branch
- **Jobs**: Terraform validation, formatting check, and planning

## Prerequisites

### 1. AWS Credentials
Add these secrets to your GitHub repository:
```
AWS_ACCESS_KEY_ID: Your AWS access key ID
AWS_SECRET_ACCESS_KEY: Your AWS secret access key
```

### 2. Required AWS Permissions
Your AWS credentials need permissions for:
- EKS cluster management
- EC2 instances and networking
- IAM roles and policies
- VPC and subnet management
- Load balancer creation

### 3. IAM Policy for S3 Backend
To allow Terraform to manage its state in an S3 bucket, you need to create an IAM policy that grants the necessary permissions. The required permissions are defined in the `iam-policy.json` file located in the `terraform/eks` directory.

Create an IAM policy using the contents of `iam-policy.json` and attach it to the IAM user or role that will be executing the Terraform commands. This policy allows Terraform to securely store and manage the state of your EKS cluster.

### 4. Existing VPC
Ensure you have a VPC with public and private subnets. Update `terraform.tfvars`:
```hcl
vpc_id = "vpc-xxxxxxxxx"
private_subnet_tags = ["*private*"]
public_subnet_tags = ["*public*"]
```

## Usage

### Method 1: Automatic Deployment
1. **Development**: Push to `feature/terraform` branch
   - Triggers validation workflow only
   - No infrastructure changes

2. **Production**: Push to `main` branch
   - Triggers validation and deployment
   - Creates EKS cluster automatically

### Method 2: Manual Deployment
1. Go to Actions tab in GitHub
2. Select "EKS-Creation-Using-Terraform" workflow
3. Click "Run workflow"
4. Choose:
   - **Action**: `plan`, `apply`, or `destroy`
   - **Environment**: `dev`, `staging`, or `production`

## Workflow Features

### Security
- Uses AWS credentials from GitHub secrets
- Environment protection for production deployments
- Terraform state validation before apply

### Efficiency
- Caches Terraform providers and modules
- Uploads/downloads Terraform plans between jobs
- Parallel execution where possible

### Monitoring
- Terraform output capture and storage
- Kubernetes cluster verification
- PR comments with plan details
- Deployment status notifications

## Terraform Configuration

### Backend Configuration
Update `terraform/eks/backend.tf` for remote state:
```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "eks/terraform.tfstate"
    region = "ap-south-1"
  }
}
```

### Variables Configuration
Update `terraform/eks/terraform.tfvars`:
```hcl
# VPC Configuration
vpc_id = "vpc-xxxxxxxxx"
aws_region = "ap-south-1"

# EKS Configuration
cluster_name = "studentai-eks"
kubernetes_version = "1.28"

# Node Group Configuration
node_instance_types = ["t3.medium"]
node_desired_size = 2
node_max_size = 4
node_min_size = 1

# Security Configuration
public_access_cidrs = ["0.0.0.0/0"]
enable_irsa = true

# Monitoring Configuration
nginx_ingress_chart_version = "4.7.1"
prometheus_chart_version = "23.1.0"
grafana_chart_version = "6.58.7"
```

## Post-Deployment Steps

### 1. Verify Cluster
```bash
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks
kubectl get nodes
kubectl get pods --all-namespaces
```

### 2. Access Monitoring
- **Prometheus**: Available via NodePort or LoadBalancer
- **Grafana**: Available via NodePort or LoadBalancer
- Check workflow outputs for URLs

### 3. Deploy Applications
Once EKS is created, you can deploy your StudentAI application:
```bash
kubectl apply -f k8s-manifests/
```

## Troubleshooting

### Common Issues

1. **Terraform State Lock**
   ```bash
   # Force unlock (use carefully)
   terraform force-unlock LOCK_ID
   ```

2. **AWS Permissions**
   - Ensure IAM user has required permissions
   - Check CloudTrail for permission errors

3. **VPC/Subnet Issues**
   - Verify VPC ID exists
   - Check subnet tags match configuration

4. **Node Group Creation Fails**
   - Check subnet availability zones
   - Verify instance type availability

### Debugging Steps

1. **Check Workflow Logs**
   - Go to Actions tab
   - Click on failed workflow
   - Review step-by-step logs

2. **Terraform State**
   - Download terraform-outputs artifact
   - Check for partial deployments

3. **AWS Console**
   - Check EKS console for cluster status
   - Review CloudFormation stacks
   - Check VPC and subnet configurations

## Environment Management

### Development Environment
- Automatic validation on feature branches
- Manual deployment approval
- Smaller instance types and node counts

### Production Environment
- Automatic deployment on main branch
- Environment protection rules
- Production-grade instance types and monitoring

## Cleanup

### Manual Cleanup
Run the destroy workflow:
1. Go to Actions tab
2. Run workflow with action: "destroy"
3. Choose appropriate environment

### Automatic Cleanup
Set up scheduled cleanup for development environments:
```yaml
# Add to workflow for scheduled cleanup
on:
  schedule:
    - cron: '0 2 * * 0'  # Every Sunday at 2 AM
```

## Cost Optimization

### Development
- Use t3.small instances
- Reduce node count
- Schedule shutdown during off-hours

### Production
- Use reserved instances
- Enable cluster autoscaler
- Monitor and optimize resource usage

## Security Best Practices

1. **Network Security**
   - Use private subnets for worker nodes
   - Restrict public access CIDRs
   - Enable VPC flow logs

2. **Access Control**
   - Use IAM roles for service accounts (IRSA)
   - Implement RBAC
   - Regular access reviews

3. **Monitoring**
   - Enable CloudTrail
   - Configure alerts
   - Regular security scanning

## Support

For issues or questions:
1. Check workflow logs first
2. Review Terraform documentation
3. Consult AWS EKS documentation
4. Create GitHub issue with detailed logs
