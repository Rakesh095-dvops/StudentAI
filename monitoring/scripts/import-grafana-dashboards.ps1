# Grafana Dashboard Import Script for Kubernetes Monitoring
# This script imports essential Kubernetes dashboards into Grafana

$GRAFANA_URL = "http://a81f8c95115704521a3bb45725a0d6ed-1687923586.ap-south-1.elb.amazonaws.com:8080"
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
        "id" = 8588
        "name" = "Kubernetes Deployment Statefulset"
        "description" = "Application deployment metrics"
    },
    @{
        "id" = 15172
        "name" = "Kubernetes / Networking / Cluster"
        "description" = "Cluster networking overview"
    },
    @{
        "id" = 12006
        "name" = "Kubernetes cluster monitoring (via Prometheus)"
        "description" = "Proven working cluster monitoring dashboard"
    },
    @{
        "id" = 10000
        "name" = "Kubernetes Cluster Monitoring"
        "description" = "Alternative lightweight cluster monitoring"
    },
    @{
        "id" = 11462
        "name" = "Node Exporter Dashboard"
        "description" = "Simplified node metrics dashboard"
    }
)

Write-Host "🚀 Starting Grafana Dashboard Import Process..." -ForegroundColor Green
Write-Host "Grafana URL: $GRAFANA_URL" -ForegroundColor Yellow

# Pre-validate dashboard availability
Write-Host "`n🔍 Pre-validating dashboard availability..." -ForegroundColor Cyan
$validDashboards = @()
foreach ($dashboard in $dashboards) {
    try {
        $testUrl = "https://grafana.com/api/dashboards/$($dashboard.id)"
        $testResponse = Invoke-RestMethod -Uri $testUrl -Method GET -TimeoutSec 10
        if ($testResponse.id -eq $dashboard.id) {
            Write-Host "   ✅ Dashboard $($dashboard.id) ($($dashboard.name)) - Available" -ForegroundColor Green
            $validDashboards += $dashboard
        }
    } catch {
        Write-Host "   ❌ Dashboard $($dashboard.id) ($($dashboard.name)) - Not available" -ForegroundColor Red
    }
}

Write-Host "`n📊 Starting import of $($validDashboards.Count) validated dashboards..." -ForegroundColor Cyan

foreach ($dashboard in $validDashboards) {
    Write-Host "`n📊 Importing: $($dashboard.name) (ID: $($dashboard.id))" -ForegroundColor Cyan
    
    try {
        # First, test Grafana connectivity
        try {
            $testResponse = Invoke-RestMethod -Uri "$GRAFANA_URL/api/health" -Method GET -Headers $headers -TimeoutSec 10
            if ($testResponse.database -eq "ok") {
                Write-Host "   🔗 Grafana connection: OK" -ForegroundColor Green
            } else {
                Write-Host "   ⚠️  Grafana health check: $($testResponse | ConvertTo-Json -Compress)" -ForegroundColor Yellow
            }
        } catch {
            Write-Host "   ⚠️  Grafana connection issue: $($_.Exception.Message)" -ForegroundColor Yellow
        }
        
        # Get dashboard JSON from Grafana.com
        $importUrl = "https://grafana.com/api/dashboards/$($dashboard.id)/revisions/latest/download"
        Write-Host "   📥 Downloading dashboard JSON..." -ForegroundColor Gray
        $dashboardJson = Invoke-RestMethod -Uri $importUrl -Method GET -TimeoutSec 30
        
        # Handle special cases for problematic dashboards
        $jsonDepth = 15  # Increased default depth
        if ($dashboard.id -eq 1860) {
            # Node Exporter Full has deep nested JSON
            $jsonDepth = 25
            Write-Host "   🔧 Using increased JSON depth for Node Exporter dashboard" -ForegroundColor Yellow
        } elseif ($dashboard.id -eq 15661 -or $dashboard.id -eq 15172) {
            # Kubernetes dashboards with complex structure
            $jsonDepth = 20
            Write-Host "   🔧 Using increased JSON depth for complex Kubernetes dashboard" -ForegroundColor Yellow
        }
        
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
        } | ConvertTo-Json -Depth $jsonDepth -Compress
        
        Write-Host "   📤 Importing to Grafana..." -ForegroundColor Gray
        # Import dashboard with better error handling
        try {
            $importResponse = Invoke-RestMethod -Uri "$GRAFANA_URL/api/dashboards/import" -Method POST -Headers $headers -Body $importPayload -TimeoutSec 30
            
            Write-Host "✅ Successfully imported: $($dashboard.name)" -ForegroundColor Green
            Write-Host "   Dashboard URL: $GRAFANA_URL/d/$($importResponse.uid)" -ForegroundColor Gray
        } catch {
            # Try alternative import method for problematic dashboards
            if ($dashboard.id -eq 1860 -or $dashboard.id -eq 6417) {
                Write-Host "   🔄 Trying alternative import method..." -ForegroundColor Yellow
                try {
                    # Use /api/dashboards/db endpoint instead
                    $altPayload = @{
                        "dashboard" = $dashboardJson
                        "overwrite" = $true
                    } | ConvertTo-Json -Depth $jsonDepth -Compress
                    
                    $importResponse = Invoke-RestMethod -Uri "$GRAFANA_URL/api/dashboards/db" -Method POST -Headers $headers -Body $altPayload -TimeoutSec 30
                    Write-Host "✅ Successfully imported via alternative method: $($dashboard.name)" -ForegroundColor Green
                    Write-Host "   Dashboard URL: $GRAFANA_URL/d/$($importResponse.uid)" -ForegroundColor Gray
                } catch {
                    throw $_.Exception
                }
            } else {
                throw $_.Exception
            }
        }
        
    } catch {
        $errorMessage = $_.Exception.Message
        $statusCode = ""
        
        # Try to extract more detailed error information
        if ($_.Exception.Response) {
            $statusCode = $_.Exception.Response.StatusCode
            Write-Host "❌ Failed to import $($dashboard.name): HTTP $statusCode - $errorMessage" -ForegroundColor Red
            
            # Try to get response body for more details
            try {
                $responseStream = $_.Exception.Response.GetResponseStream()
                $reader = New-Object System.IO.StreamReader($responseStream)
                $responseText = $reader.ReadToEnd()
                $reader.Close()
                $responseStream.Close()
                
                if ($responseText) {
                    Write-Host "   📋 Error details: $responseText" -ForegroundColor Red
                    
                    # Check for specific error patterns
                    if ($responseText -like "*datasource*" -or $responseText -like "*DS_PROMETHEUS*") {
                        Write-Host "   🔧 Hint: This might be a datasource configuration issue" -ForegroundColor Yellow
                        Write-Host "   💡 Ensure Prometheus datasource is configured and named 'Prometheus'" -ForegroundColor Yellow
                    } elseif ($responseText -like "*validation*" -or $responseText -like "*invalid*") {
                        Write-Host "   🔧 Hint: Dashboard JSON validation failed - dashboard may be incompatible" -ForegroundColor Yellow
                    }
                }
            } catch {
                # Ignore if we can't read the error body
            }
        } else {
            Write-Host "❌ Failed to import $($dashboard.name): $errorMessage" -ForegroundColor Red
        }
        
        # Suggest alternatives for known problematic dashboards
        if ($dashboard.id -eq 6417) {
            Write-Host "   💡 Try alternatives: Dashboard 12006 (Kubernetes cluster monitoring) or 10000 (Kubernetes Cluster Monitoring)" -ForegroundColor Yellow
        } elseif ($dashboard.id -eq 15661 -or $dashboard.id -eq 13332) {
            Write-Host "   💡 Try alternative: Dashboard 12006 (Kubernetes cluster monitoring) for cluster monitoring" -ForegroundColor Yellow
        } elseif ($dashboard.id -eq 1860 -or $dashboard.id -eq 11074) {
            Write-Host "   💡 Try alternative: Dashboard 11462 (Node Exporter Dashboard) for simpler node metrics" -ForegroundColor Yellow
        }
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
