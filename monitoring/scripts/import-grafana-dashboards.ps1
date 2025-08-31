# Grafana Dashboard Import Script for Kubernetes Monitoring
# This script imports essential Kubernetes dashboards into Grafana

$GRAFANA_URL = "http://a6957f908d66943138ea88806f0be28d-486608417.ap-south-1.elb.amazonaws.com:8080"
$GRAFANA_USER = "admin"
$GRAFANA_PASS = "admin123"

# Create Basic Auth header
$pair = "$($GRAFANA_USER):$($GRAFANA_PASS)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($pair))
$basicAuthValue = "Basic $encodedCreds"

$headers = @{
    "Authorization" = $basicAuthValue
    "Content-Type" = "application/json"
}

# Essential Kubernetes Dashboard IDs from Grafana.com
$dashboards = @(
    @{
        "id" = 15757
        "name" = "Kubernetes / Views / Pods"
        "description" = "Detailed pod-level metrics"
    },
    @{
        "id" = 15758
        "name" = "Kubernetes / Views / Namespaces"
        "description" = "Namespace-level resource usage"
    },
    @{
        "id" = 15759
        "name" = "Kubernetes / Views / Nodes"
        "description" = "Node-level resource utilization"
    },
    @{
        "id" = 15760
        "name" = "Kubernetes / Views / Global"
        "description" = "Cluster-wide overview"
    },
    @{
        "id" = 6417
        "name" = "Kubernetes Cluster Monitoring"
        "description" = "Complete cluster monitoring"
    },
    @{
        "id" = 8588
        "name" = "Kubernetes Deployment Statefulset"
        "description" = "Application deployment metrics"
    },
    @{
        "id" = 1860
        "name" = "Node Exporter Full"
        "description" = "Detailed node metrics"
    }
)

Write-Host "🚀 Starting Grafana Dashboard Import Process..." -ForegroundColor Green
Write-Host "Grafana URL: $GRAFANA_URL" -ForegroundColor Yellow

foreach ($dashboard in $dashboards) {
    Write-Host "`n📊 Importing: $($dashboard.name) (ID: $($dashboard.id))" -ForegroundColor Cyan
    
    try {
        # Get dashboard JSON from Grafana.com
        $importUrl = "https://grafana.com/api/dashboards/$($dashboard.id)/revisions/latest/download"
        $dashboardJson = Invoke-RestMethod -Uri $importUrl -Method GET
        
        # Prepare import payload
        $importPayload = @{
            "dashboard" = $dashboardJson
            "overwrite" = $true
            "inputs" = @(
                @{
                    "name" = "DS_PROMETHEUS"
                    "type" = "datasource"
                    "pluginId" = "prometheus"
                    "value" = "Prometheus"
                }
            )
        } | ConvertTo-Json -Depth 10
        
        # Import dashboard
        $importResponse = Invoke-RestMethod -Uri "$GRAFANA_URL/api/dashboards/import" -Method POST -Headers $headers -Body $importPayload
        
        Write-Host "✅ Successfully imported: $($dashboard.name)" -ForegroundColor Green
        Write-Host "   Dashboard URL: $GRAFANA_URL/d/$($importResponse.uid)" -ForegroundColor Gray
        
    } catch {
        Write-Host "❌ Failed to import $($dashboard.name): $($_.Exception.Message)" -ForegroundColor Red
    }
    
    Start-Sleep -Seconds 2
}

Write-Host "`n🎉 Dashboard import process completed!" -ForegroundColor Green
Write-Host "`n📋 Quick Access URLs:" -ForegroundColor Yellow
Write-Host "   Grafana Home: $GRAFANA_URL" -ForegroundColor Gray
Write-Host "   Dashboards: $GRAFANA_URL/dashboards" -ForegroundColor Gray
Write-Host "   Data Sources: $GRAFANA_URL/datasources" -ForegroundColor Gray

Write-Host "`n🔧 Next Steps:" -ForegroundColor Yellow
Write-Host "1. Login to Grafana: $GRAFANA_URL (admin/admin123)" -ForegroundColor Gray
Write-Host "2. Navigate to Dashboards > Browse" -ForegroundColor Gray
Write-Host "3. Explore imported Kubernetes dashboards" -ForegroundColor Gray
Write-Host "4. Customize alerts and notifications" -ForegroundColor Gray
