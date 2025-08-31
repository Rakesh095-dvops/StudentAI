# Grafana Alerting Configuration for Kubernetes

## Alert Rules Configuration

### 1. High CPU Usage Alert
Rule Name: High CPU Usage
Condition: avg(rate(container_cpu_usage_seconds_total{namespace="studentai"}[5m])) > 0.8
Description: CPU usage is above 80% for StudentAI pods
Severity: Warning
Duration: 5m

### 2. High Memory Usage Alert  
Rule Name: High Memory Usage
Condition: avg(container_memory_working_set_bytes{namespace="studentai"}) / avg(container_spec_memory_limit_bytes{namespace="studentai"}) > 0.9
Description: Memory usage is above 90% for StudentAI pods
Severity: Critical
Duration: 2m

### 3. Pod Restart Alert
Rule Name: Pod Restarts
Condition: increase(kube_pod_container_restarts_total{namespace="studentai"}[10m]) > 0
Description: Pod has restarted in the last 10 minutes
Severity: Warning
Duration: 0m

### 4. Pod Not Ready Alert
Rule Name: Pod Not Ready
Condition: kube_pod_status_ready{namespace="studentai", condition="false"} == 1
Description: Pod is not in ready state
Severity: Critical
Duration: 5m

### 5. Node Resource Alert
Rule Name: Node High Resource Usage
Condition: (1 - avg(node_memory_MemAvailable_bytes) / avg(node_memory_MemTotal_bytes)) > 0.85
Description: Node memory usage is above 85%
Severity: Warning
Duration: 5m

## Contact Points Configuration

### Email Notifications
1. Go to Grafana -> Alerting -> Contact points
2. Add new contact point:
   - Name: "email-alerts"
   - Type: "Email"
   - Addresses: your-team@company.com
   - Subject: "[ALERT] {{.GroupLabels.alertname}} - {{.GroupLabels.severity}}"

### Slack Notifications  
1. Add Slack contact point:
   - Name: "slack-alerts"
   - Type: "Slack"
   - Webhook URL: your-slack-webhook-url
   - Channel: #monitoring
   - Title: "Kubernetes Alert: {{.GroupLabels.alertname}}"

## Notification Policies
1. Go to Alerting -> Notification policies
2. Configure routing:
   - Critical alerts: Send to both Email and Slack immediately
   - Warning alerts: Send to Slack with 5-minute grouping
   - Info alerts: Send to Email daily digest

## Quick Setup Commands
```bash
# Import alert rules via API
curl -X POST \\
  http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080/api/ruler/grafana/api/v1/rules/namespace \\
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM=" \\
  -H "Content-Type: application/json" \\
  -d @alert-rules.json
```

## Testing Alerts
```bash
# Simulate high CPU usage
kubectl run cpu-stress --image=progrium/stress --namespace=studentai -- --cpu 2 --timeout 300s

# Simulate memory pressure  
kubectl run memory-stress --image=progrium/stress --namespace=studentai -- --vm 1 --vm-bytes 512M --timeout 300s

# Check alert status
curl -s "http://ae6cc362b0c0f490989212fceb5eeee3-62917191.ap-south-1.elb.amazonaws.com:9090/api/v1/alerts" | jq '.data[] | select(.state=="firing")'
```

Successfully Imported Dashboards:
✅ Kubernetes / Views / Pods (15757)
✅ Kubernetes / Views / Namespaces (15758)
✅ Kubernetes / Views / Nodes (15759)
✅ Kubernetes / Views / Global (15760)
✅ Kubernetes Deployment Statefulset (8588)
✅ Kubernetes / Networking / Cluster (15172)
✅ Kubernetes cluster monitoring (via Prometheus) (12006) - Great cluster overview
✅ Kubernetes Cluster Monitoring (10000) - Alternative cluster monitoring
✅ Node Exporter Dashboard (11462) - Working node metrics alternative