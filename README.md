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


# Terraform EKS provision 

Provision EKS using  `*.tf` files `/terraform` folder . 
- EKS will use default VPC subnets in AWS . 
- Once provision is completed EKS will use nginx ingress controller to route traffic to prometheus and grafana. 

## Key Features:
- Auto-scaling EKS cluster (1-4 nodes) with proper IAM roles
- NGINX Ingress Controller with metrics and NLB integration
- Network access configured for StudentAI application ports
- Monitoring stack (Prometheus + Grafana) with proper ingress
- Infrastructure-only approach - ready for separate ArgoCD deployment

## Next Steps:
- Update terraform.tfvars with your actual VPC details
- Run `terraform init && terraform plan && terraform apply`
- Deploy ArgoCD separately using your preferred method
- Configure your StudentAI application manifests for the NGINX ingress

## helpful commands 
- `terraform fmt`
- `terraform init`
- `terraform validate`

## 🔧 Error Analysis and Solutions

1. Helm Repository Issues

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm repo list
helm repo update
```
2. K8s EKS commands 

```bash
aws eks list-clusters --region ap-south-1 
# The cluster was created successfully. Let me configure kubectl:
aws eks update-kubeconfig --region ap-south-1 --name studentai-eks-dev
kubectl get nodes
kubectl get nodes -o wide
kubectl get pods -n monitoring
kubectl describe pod grafana-778b9b4bc6-cvxpr -n monitoring
kubectl get pods -n kube-system | grep ebs
kubectl get pvc -n monitoring
kubectl get pods -n ingress-nginx
kubectl get pods -n kube-system | Select-String "cluster-autoscaler"
```
```sh
aws iam list-policies --query 'Policies[?contains(PolicyName,`EBS`)].[PolicyName,Arn]' --output table
```
🚀 Access Your Infrastructure:
- Grafana Dashboard (Port 8080):
```sh
kubectl port-forward -n monitoring svc/grafana 8080:8080
# Access at: http://localhost:8080
# Username: admin
# Password: admin123
```
- Prometheus Metrics (Port 9090):

```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Access at: http://localhost:9090
```
- NGINX Ingress External IP:
```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller
```

📊 Cluster Resources:
- Nodes: 3 x t3.medium in public subnets
- Kubernetes Version: 1.30 (latest stable)
- Region: ap-south-1
- VPC: vpc-0056d809452f9f8ea

🎯 Ready for StudentAI Deployment:
- Your infrastructure is now ready for StudentAI application deployment via ArgoCD! The ports are properly configured:

- StudentAI Auth: 3001 ✅
- StudentAI UserDetails: 3002 ✅
- StudentAI Frontend: 80 ✅
- Grafana: 8080 ✅ (no conflicts)
- Prometheus: 9090 ✅