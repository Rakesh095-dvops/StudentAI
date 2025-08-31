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

### Linux/Mac (bash)
```bash
# Import alert rules via API
curl -X POST \
  http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080/api/ruler/grafana/api/v1/rules/namespace \
  -H "Authorization: Basic YWRtaW46YWRtaW4xMjM=" \
  -H "Content-Type: application/json" \
  -d @alert-rules.json
```

### PowerShell (Windows)
```powershell
# Import alert rules via API using PowerShell
$grafanaUrl = "http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080"
$headers = @{
    "Authorization" = "Basic YWRtaW46YWRtaW4xMjM="
    "Content-Type" = "application/json"
}

# Read alert rules from file
$alertRulesJson = Get-Content -Path "alert-rules.json" -Raw

try {
    $response = Invoke-RestMethod -Uri "$grafanaUrl/api/ruler/grafana/api/v1/rules/namespace" -Method POST -Headers $headers -Body $alertRulesJson
    Write-Host "✅ Alert rules imported successfully" -ForegroundColor Green
} catch {
    Write-Host "❌ Failed to import alert rules: $($_.Exception.Message)" -ForegroundColor Red
}
```

## Testing Alerts
```bash
# Simulate high CPU usage
kubectl run cpu-stress --image=progrium/stress --namespace=studentai -- --cpu 2 --timeout 300s

# Simulate memory pressure  
kubectl run memory-stress --image=progrium/stress --namespace=studentai -- --vm 1 --vm-bytes 512M --timeout 300s

# Check alert status (Linux/Mac with jq)
curl -s "http://a5f01fc24551d492aaa4216c20588f34-1429811828.ap-south-1.elb.amazonaws.com:9090/api/v1/alerts" | jq '.data[] | select(.state=="firing")'
```

### PowerShell Alternative (Windows)
```powershell
# Check Prometheus alerts using PowerShell
$prometheusUrl = "http://a5f01fc24551d492aaa4216c20588f34-1429811828.ap-south-1.elb.amazonaws.com:9090/api/v1/alerts"

try {
    Write-Host "🔍 Checking Prometheus alerts..." -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $prometheusUrl -Method GET -TimeoutSec 15
    
    if ($response.status -eq "success") {
        $firingAlerts = $response.data | Where-Object { $_.state -eq "firing" }
        
        if ($firingAlerts.Count -gt 0) {
            Write-Host "🚨 Found $($firingAlerts.Count) firing alerts:" -ForegroundColor Red
            foreach ($alert in $firingAlerts) {
                Write-Host "   Alert: $($alert.labels.alertname)" -ForegroundColor Yellow
                Write-Host "   State: $($alert.state)" -ForegroundColor Red
                Write-Host "   Value: $($alert.value)" -ForegroundColor Gray
                Write-Host "   ---"
            }
        } else {
            Write-Host "✅ No firing alerts found" -ForegroundColor Green
        }
        
        # Show pending alerts too
        $pendingAlerts = $response.data | Where-Object { $_.state -eq "pending" }
        if ($pendingAlerts.Count -gt 0) {
            Write-Host "⏳ Found $($pendingAlerts.Count) pending alerts:" -ForegroundColor Yellow
            $pendingAlerts | ForEach-Object { Write-Host "   - $($_.labels.alertname)" }
        }
    }
} catch {
    Write-Host "❌ Failed to connect to Prometheus: $($_.Exception.Message)" -ForegroundColor Red
}
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