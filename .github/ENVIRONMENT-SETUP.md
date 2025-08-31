# GitHub Environment Configuration

This document explains how to set up GitHub environments for your EKS deployment workflows.

## Environment Setup

### 1. Create Environments

Go to your repository Settings → Environments and create:

#### Development Environment
- **Name**: `development`
- **Protection Rules**: None (for quick testing)
- **Secrets**: Same as repository secrets
- **Variables**:
  ```
  ENVIRONMENT_NAME=development
  CLUSTER_NAME=studentai-eks-dev
  NODE_DESIRED_SIZE=1
  NODE_MAX_SIZE=2
  NODE_MIN_SIZE=1
  ```

#### Staging Environment
- **Name**: `staging`
- **Protection Rules**: 
  - Required reviewers: 1
  - Wait timer: 5 minutes
- **Secrets**: Same as repository secrets
- **Variables**:
  ```
  ENVIRONMENT_NAME=staging
  CLUSTER_NAME=studentai-eks-staging
  NODE_DESIRED_SIZE=2
  NODE_MAX_SIZE=4
  NODE_MIN_SIZE=1
  ```

#### Production Environment
- **Name**: `production`
- **Protection Rules**:
  - Required reviewers: 2
  - Wait timer: 10 minutes
  - Restrict to main branch only
- **Secrets**: Production AWS credentials
- **Variables**:
  ```
  ENVIRONMENT_NAME=production
  CLUSTER_NAME=studentai-eks-prod
  NODE_DESIRED_SIZE=3
  NODE_MAX_SIZE=6
  NODE_MIN_SIZE=2
  ```

### 2. Repository Secrets

Add these secrets at the repository level:

```
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
```

### 3. Environment-Specific Variables

For each environment, you can override variables:

#### Development
```
TF_VAR_node_instance_types=["t3.small"]
TF_VAR_enable_monitoring=false
```

#### Staging
```
TF_VAR_node_instance_types=["t3.medium"]
TF_VAR_enable_monitoring=true
```

#### Production
```
TF_VAR_node_instance_types=["t3.large"]
TF_VAR_enable_monitoring=true
TF_VAR_enable_logging=true
```

## Protection Rules

### Branch Protection
- Main branch: Require PR reviews, status checks
- Feature branches: Allow direct pushes for development

### Environment Protection
- Development: No restrictions
- Staging: 1 reviewer required
- Production: 2 reviewers + wait timer

### Deployment Approvals
Configure who can approve deployments:
- Development: Any team member
- Staging: Team leads
- Production: Senior engineers + DevOps team

## Usage Examples

### Deploy to Development
```bash
# Automatic on feature branch push
git push origin feature/new-feature

# Manual deployment
# Go to Actions → EKS-Creation-Using-Terraform → Run workflow
# Select: action=apply, environment=development
```

### Deploy to Staging
```bash
# Create PR to main branch
# After merge, manually trigger with environment=staging
```

### Deploy to Production
```bash
# Manual deployment with approvals
# Go to Actions → EKS-Creation-Using-Terraform → Run workflow
# Select: action=apply, environment=production
# Wait for approvals
```

## Monitoring and Notifications

### Slack Integration (Optional)
Add webhook URL to environment secrets:
```
SLACK_WEBHOOK_URL=https://hooks.slack.com/...
```

### Email Notifications
Configure in repository settings:
- Workflow failures
- Deployment approvals needed
- Security alerts
