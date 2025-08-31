# 🚀 Complete EKS + ArgoCD Deployment Guide

## Step-by-Step Execution Instructions

### Phase 1: Prerequisites Setup

#### 1.1 AWS Setup
```bash
# Configure AWS CLI
aws configure
# Enter your AWS Access Key ID, Secret Access Key, region (ap-south-1), and output format (json)

# Verify AWS connection
aws sts get-caller-identity
```

#### 1.2 GitHub Repository Setup
1. Go to your repository: https://github.com/Rakesh095-dvops/StudentAI
2. Navigate to Settings → Secrets and variables → Actions
3. Add repository secrets:
   ```
   AWS_ACCESS_KEY_ID: your-aws-access-key-id
   AWS_SECRET_ACCESS_KEY: your-aws-secret-access-key
   ```

#### 1.3 Update Terraform Variables
Edit `terraform/eks/terraform.tfvars`:
```hcl
# Replace with your actual VPC ID
vpc_id = "vpc-your-actual-vpc-id"

# Keep other settings as needed
cluster_name = "studentai-eks"
kubernetes_version = "1.28"
node_instance_types = ["t3.medium"]
node_desired_size = 2
node_max_size = 4
node_min_size = 1
```

### Phase 2: EKS Cluster Deployment

#### 2.1 Deploy EKS Cluster via GitHub Actions

**Method A: Automatic Deployment**
```bash
# Commit and push to main branch
git add .
git commit -m "Deploy EKS cluster with Terraform"
git push origin main

# This triggers the EKS-Creation-Using-Terraform workflow automatically
```

**Method B: Manual Deployment**
1. Go to GitHub → Actions
2. Select "EKS-Creation-Using-Terraform" workflow
3. Click "Run workflow"
4. Select:
   - Action: `apply`
   - Environment: `dev`
5. Click "Run workflow"

#### 2.2 Monitor Deployment
1. Go to GitHub → Actions
2. Click on the running workflow
3. Monitor each job:
   - ✅ Terraform Validate
   - ✅ Terraform Apply
   - ✅ Verify EKS Cluster

#### 2.3 Verify EKS Cluster
```bash
# Update kubeconfig
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks

# Verify cluster
kubectl get nodes
kubectl get pods --all-namespaces

# Check cluster info
kubectl cluster-info
```

### Phase 3: ArgoCD Installation

#### 3.1 Install ArgoCD using Setup Script
```bash
# Make the script executable
chmod +x argocd/setup.sh

# Run the setup script
./argocd/setup.sh
```

#### 3.2 Access ArgoCD UI
```bash
# Get ArgoCD admin password (from setup script output)
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser: https://localhost:8080
# Username: admin
# Password: (from above command)
```

#### 3.3 Verify ArgoCD Installation
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Check applications
kubectl get applications -n argocd
```

### Phase 4: Configure ArgoCD for StudentAI

#### 4.1 Add Repository to ArgoCD
In ArgoCD UI:
1. Go to Settings → Repositories
2. Click "Connect Repo"
3. Enter:
   - Repository URL: `https://github.com/Rakesh095-dvops/StudentAI.git`
   - Connection Method: Via HTTPS
4. Click "Connect"

#### 4.2 Create Applications
The applications are automatically created by the setup script:
- `studentai-frontend`
- `studentai-backend-auth`
- `studentai-backend-userdetails`
- `studentai-backend-payments`

#### 4.3 Verify Applications in ArgoCD
1. Go to Applications in ArgoCD UI
2. You should see all StudentAI applications
3. Check sync status

### Phase 5: CI/CD Pipeline Setup

#### 5.1 Add ArgoCD Secrets to GitHub
```bash
# Get ArgoCD admin password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Add to GitHub secrets:
# ARGOCD_SERVER: your-argocd-server-url (e.g., localhost:8080 or your-domain.com)
# ARGOCD_PASSWORD: (password from above)
```

#### 5.2 Test CI/CD Pipeline
```bash
# Make a change to frontend or backend code
echo "// Test change" >> frontend/src/app/page.js

# Commit and push
git add .
git commit -m "Test CI/CD pipeline"
git push origin main

# This triggers:
# 1. Build Docker images
# 2. Push to ECR
# 3. Update Kubernetes manifests
# 4. Trigger ArgoCD sync
```

### Phase 6: Verification and Testing

#### 6.1 Check Application Deployment
```bash
# Check pods in studentai namespace
kubectl get pods -n studentai

# Check services
kubectl get svc -n studentai

# Check ingress
kubectl get ingress -n studentai
```

#### 6.2 Access Applications
```bash
# Get LoadBalancer URL for frontend
kubectl get svc studentai-frontend -n studentai

# Or use port-forward for testing
kubectl port-forward svc/studentai-frontend -n studentai 3000:80

# Open browser: http://localhost:3000
```

#### 6.3 Monitor with ArgoCD
1. Open ArgoCD UI
2. Click on each application
3. Verify sync status
4. Check application health

### Phase 7: Monitoring Setup

#### 7.1 Access Grafana (if monitoring is enabled)
```bash
# Get Grafana service
kubectl get svc -n monitoring

# Port forward to Grafana
kubectl port-forward svc/grafana -n monitoring 3001:80

# Open browser: http://localhost:3001
# Default credentials: admin/admin
```

#### 7.2 Access Prometheus
```bash
# Port forward to Prometheus
kubectl port-forward svc/prometheus-server -n monitoring 9090:80

# Open browser: http://localhost:9090
```

## 🔧 Troubleshooting Commands

### EKS Issues
```bash
# Check EKS cluster status
aws eks describe-cluster --name studentai-eks

# Check node group
aws eks describe-nodegroup --cluster-name studentai-eks --nodegroup-name studentai-eks-nodes

# Check CloudFormation stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE
```

### ArgoCD Issues
```bash
# Check ArgoCD pods
kubectl get pods -n argocd

# Get ArgoCD server logs
kubectl logs -f deployment/argocd-server -n argocd

# Check application status
kubectl get applications -n argocd

# Restart ArgoCD server
kubectl rollout restart deployment/argocd-server -n argocd
```

### Application Issues
```bash
# Check application pods
kubectl get pods -n studentai

# Get pod logs
kubectl logs -f deployment/studentai-frontend -n studentai

# Describe pod for events
kubectl describe pod <pod-name> -n studentai

# Check events in namespace
kubectl get events -n studentai --sort-by=.metadata.creationTimestamp
```

### CI/CD Issues
```bash
# Check GitHub Actions workflow logs
# Go to GitHub → Actions → Select failed workflow → View logs

# Check if images are pushed to ECR
aws ecr-public describe-repositories --region us-east-1

# List images in repository
aws ecr-public describe-images --repository-name studentai/frontend --region us-east-1
```

## 🎯 Success Checklist

- [ ] EKS cluster deployed successfully
- [ ] ArgoCD installed and accessible
- [ ] All StudentAI applications deployed
- [ ] CI/CD pipeline functional
- [ ] Applications accessible via LoadBalancer/Ingress
- [ ] Monitoring stack operational (if enabled)
- [ ] ArgoCD syncing applications automatically

## 🚨 Important Notes

1. **Costs**: Running EKS cluster incurs AWS costs. Monitor usage.
2. **Security**: Use proper RBAC and network policies in production.
3. **Backups**: Implement backup strategy for persistent data.
4. **Monitoring**: Set up alerts for application and cluster health.
5. **Updates**: Keep Kubernetes, ArgoCD, and applications updated.

## 🆘 Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review GitHub Actions logs
3. Check ArgoCD application status
4. Verify AWS resources in console
5. Check Kubernetes events and logs
