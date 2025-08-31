# StudentAI

## Helpful Docker Compose Commands
### docker build command
```sh
docker build -t userdetails:latest .
docker build -t auth:latest .
docker build -t testfe:latest .
```
### docker-compose 
```sh
# Build and start all services
docker-compose up -d
docker-compose up -d --build
# Verify all containers are running
docker-compose ps

# View logs for all services
docker-compose logs -f

# Stop all services
docker-compose down

#Rebuild the Docker Images
#Run the following command to rebuild the Docker images:
docker-compose build testfe
# Debug the Build Context
docker build --no-cache -t testfe ./testfe
#Inspect the Container
docker-compose up -d testfe
docker exec -it testfe sh
ls /usr/src/app
# Check health status specifically
docker inspect --format='{{json .State.Health}}' testfe
#Clean Up Docker Cache
docker-compose down --rmi all --volumes --remove-orphans 
docker-compose build --no-cache
docker-compose up
```


## Backend API

### Authentication

- http://localhost:3001/auth/health
- http://localhost:3001/auth/organization
- http://localhost:3001/auth/user

#### Environment Variables

```sh
MONGO_URI=
JWT_TOKEN=
AWS_KEY_ID=
AWS_SECRET_KEY=
AWS_REGION=ap-south-1
SENDING_EMAIL_THROUGH=
PORT=3001
```

### userDetails API 

- http://localhost:3002/api/basicresume
- http://localhost:3002/api/organization
- http://localhost:3002/api/org/userDetails

#### Environment Variables

```sh
MONGO_URI=
JWT_TOKEN=
AWS_KEY_ID=
AWS_SECRET_KEY=
AWS_REGION=ap-south-1
SENDING_EMAIL_THROUGH=
AWS_BUCKET=studentai-bucket
PORT=3002
OPENAI_API_KEY=
OPENAI_ORG_ID=
OPENAI_API_BASE=https://api.openai.com/v1
```

### Notes: 
- Create a  OPENAPI key and get details using ***[https://platform.openai.com/](https://platform.openai.com/)***
- Create `AWS_SECRET_KEY` and `AWS_KEY_ID` using aws profile use own or create new use using IAM to create application specific user and create relevant keys. 
- For `SENDING_EMAIL_THROUGH` create earlier IAM custom user create email or for SES service user account own Email
- create s3 bucket `AWS_BUCKET`
- Create `JWT_TOKEN` for the application 
   
   ```bash
   node -e "console.log(require('crypto').randomBytes(64).toString('hex'))"
   ```

## Frontend 

- http://localhost:80


# Terraform EKS Infrastructure 

Deploy a complete EKS cluster with monitoring stack using Terraform in the `/terraform` folder.

## 🚀 Deployment Status: ACTIVE ✅

Your EKS cluster is successfully deployed and operational with the following configuration:
- **Cluster Name**: `studentai-eks-dev`
- **Region**: `ap-south-1`
- **Kubernetes Version**: `1.30`
- **Status**: `ACTIVE`

## Key Features:
- ✅ Auto-scaling EKS cluster (1-4 nodes) with t3.small instances
- ✅ AWS LoadBalancer services for external access (no port forwarding needed)
- ✅ Monitoring stack (Prometheus + Grafana) with LoadBalancer endpoints
- ✅ Network access configured for StudentAI application ports
- ✅ Comprehensive output files (JSON/TXT) with deployment details
- ✅ Production-ready infrastructure with persistent external access

## 📋 Quick Start:
1. Configure kubectl access:
```bash
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks-dev
```

2. Verify cluster status:
```bash
kubectl get nodes
kubectl get svc -n monitoring
```

## 🌐 Direct Access URLs (No Port Forwarding Required):

### Grafana Dashboard
- **URL**: http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080
- **Username**: `admin`
- **Password**: `admin123`
- **Service Type**: LoadBalancer (AWS ALB)

### Prometheus Metrics
- **URL**: http://ae6cc362b0c0f490989212fceb5eeee3-62917191.ap-south-1.elb.amazonaws.com:9090
- **Service Type**: LoadBalancer (AWS ALB)

## 📊 Generated Output Files:
- `terraform/eks/output.json` - Comprehensive deployment information in JSON format
- `terraform/eks/output.txt` - Human-readable deployment summary

## Next Steps for Application Deployment:
- Deploy StudentAI applications using Kubernetes manifests
- Configure ingress rules for your applications
- Set up CI/CD pipelines with ArgoCD or similar tools

## 🔧 Terraform Commands

```bash
# Format Terraform files
terraform fmt

# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply configuration
terraform apply -auto-approve
```

## 🔧 Troubleshooting & Maintenance

### 1. Helm Repository Management
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# List and update repositories
helm repo list
helm repo update
```

### 2. Essential Kubernetes Commands
```bash
# Cluster management
aws eks list-clusters --region ap-south-1 
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks-dev

# Node and pod monitoring
kubectl get nodes -o wide
kubectl get pods -n monitoring
kubectl get svc -n monitoring -o wide

# Service debugging
kubectl describe pod <pod-name> -n monitoring
kubectl logs -n monitoring deployment/grafana
kubectl logs -n monitoring deployment/prometheus-kube-prometheus-prometheus

# Check LoadBalancer status
kubectl get svc -n monitoring | grep LoadBalancer
```

### 3. AWS IAM Policy Check
```bash
aws iam list-policies --query 'Policies[?contains(PolicyName,`EBS`)].[PolicyName,Arn]' --output table
```

## 🎯 Alternative Access Methods (Optional):

If you prefer port forwarding instead of LoadBalancer URLs:

### Grafana (Port Forwarding):
```bash
kubectl port-forward -n monitoring svc/grafana 3000:8080
# Access at: http://localhost:3000
```

### Prometheus (Port Forwarding):
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Access at: http://localhost:9090
```

## 📊 Infrastructure Details:
- **Nodes**: Auto-scaling (1-4) x t3.small instances
- **Kubernetes Version**: 1.30 (latest stable)
- **Region**: ap-south-1
- **High Availability**: Multi-AZ deployment
- **Load Balancing**: AWS Application Load Balancers
- **Monitoring**: Prometheus + Grafana stack
- **Storage**: EBS CSI driver for persistent volumes

## � Production Ready Features:
✅ **External Access**: Direct LoadBalancer URLs (no local dependencies)  
✅ **Team Collaboration**: Shareable URLs for multiple users  
✅ **High Availability**: Multi-AZ EKS cluster deployment  
✅ **Auto Scaling**: Dynamic node scaling based on workload  
✅ **Monitoring**: Complete observability stack with persistent data  
✅ **Security**: IAM roles and policies properly configured  

## 🎯 Ready for StudentAI Application Deployment:

Your infrastructure is production-ready for StudentAI application deployment:

- **StudentAI Auth Service**: Port 3001 ✅
- **StudentAI UserDetails Service**: Port 3002 ✅  
- **StudentAI Frontend**: Port 80 ✅
- **Grafana Dashboard**: Port 8080 ✅ (LoadBalancer)
- **Prometheus Metrics**: Port 9090 ✅ (LoadBalancer)

The cluster is now ready for application manifests and CI/CD pipeline integration!

---

## 🧪 Sample Application Deployment Guide

### Deploy Hello World Kubernetes Application

To test your EKS cluster and verify Prometheus monitoring, you can deploy a sample application:

#### 1. Create Hello World Deployment
```yaml
# hello-world-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  namespace: studentai
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
      - name: hello-world
        image: nginx:latest
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
---
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
  namespace: studentai
spec:
  selector:
    app: hello-world
  ports:
  - port: 80
    targetPort: 80
  type: LoadBalancer
```

#### 2. Deploy the Application
```bash
# Create namespace if it doesn't exist
kubectl create namespace studentai

# Apply the deployment
kubectl apply -f hello-world-deployment.yaml

# Check deployment status
kubectl get pods -n studentai
kubectl get svc -n studentai

# Get LoadBalancer URL
kubectl get svc hello-world-service -n studentai -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
```

#### 3. Verify Monitoring Integration
```bash
# Check if metrics are being collected
kubectl top nodes
kubectl top pods -n studentai

# View metrics in Prometheus
# Open: http://ae6cc362b0c0f490989212fceb5eeee3-62917191.ap-south-1.elb.amazonaws.com:9090
# Query: up{job="kubernetes-pods"}
```

#### 4. View in Grafana Dashboard
- Open Grafana: http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080
- Login with admin/admin123
- Navigate to Dashboards → Kubernetes cluster monitoring
- Verify your hello-world pods are visible in the metrics

#### 5. Cleanup (Optional)
```bash
kubectl delete -f hello-world-deployment.yaml
```

This sample deployment helps verify that:
- ✅ EKS cluster is working correctly
- ✅ LoadBalancer services are functional  
- ✅ Prometheus is collecting metrics
- ✅ Grafana is displaying cluster data
- ✅ Your cluster is ready for production workloads