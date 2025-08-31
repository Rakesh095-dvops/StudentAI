# 📊 Monitoring Infrastructure

This folder contains all monitoring-related configurations, documentation, and scripts for the StudentAI Kubernetes cluster.

## 📁 Folder Structure

```
monitoring/
├── configs/                          # Configuration files
│   ├── grafana-alerts-guide.md      # Grafana alerting setup guide
│   └── studentai-dashboard.json     # Custom StudentAI Grafana dashboard
├── docs/                            # Documentation
│   └── monitoring-setup-complete.md # Complete monitoring setup guide
├── k8s-manifests/                   # Kubernetes manifests
│   └── monitoring/
│       └── servicemonitor.yaml      # ServiceMonitor for custom apps
├── scripts/                         # Automation scripts
│   └── import-grafana-dashboards.ps1 # Grafana dashboard import script
└── README.md                        # This file
```

## 🚀 Quick Access

### Live Monitoring URLs
- **Grafana Dashboard**: http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080
- **Prometheus Metrics**: http://ae6cc362b0c0f490989212fceb5eeee3-62917191.ap-south-1.elb.amazonaws.com:9090

### Credentials
- **Username**: admin
- **Password**: admin123

## 📋 Available Resources

### 🔧 Configuration Files
- **`configs/grafana-alerts-guide.md`** - Complete guide for setting up Grafana alerts and notifications
- **`configs/studentai-dashboard.json`** - Custom dashboard template for StudentAI applications

### 📚 Documentation  
- **`docs/monitoring-setup-complete.md`** - Comprehensive setup guide and troubleshooting

### 🎛️ Kubernetes Manifests
- **`k8s-manifests/monitoring/servicemonitor.yaml`** - ServiceMonitor configuration for monitoring custom applications

### 🤖 Automation Scripts
- **`scripts/import-grafana-dashboards.ps1`** - PowerShell script to automatically import essential Kubernetes dashboards

## 🔄 Usage Examples

### Import Dashboards
```powershell
cd monitoring/scripts
.\import-grafana-dashboards.ps1
```

### Deploy Custom Monitoring
```bash
kubectl apply -f monitoring/k8s-manifests/monitoring/servicemonitor.yaml
```

### Import Custom Dashboard
```bash
# Navigate to Grafana → Dashboards → Import
# Upload: monitoring/configs/studentai-dashboard.json
```

## 📊 Current Status

✅ **Prometheus**: Collecting from 23+ targets  
✅ **Grafana**: 8 imported Kubernetes dashboards  
✅ **LoadBalancer**: External access configured  
✅ **Node Exporter**: All 3 nodes monitored  
✅ **Kube-state-metrics**: Kubernetes objects tracked  

## 🔗 Related Infrastructure

This monitoring setup is part of the larger StudentAI infrastructure:
- **EKS Cluster**: `../terraform/eks/` - Terraform infrastructure
- **Applications**: `../backend/`, `../frontend/` - Application code
- **Testing**: `../testFE/` - Frontend testing environment

## 📞 Support

For troubleshooting and additional configuration, refer to:
- `docs/monitoring-setup-complete.md` - Complete documentation
- `configs/grafana-alerts-guide.md` - Alert configuration guide
