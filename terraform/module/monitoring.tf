# Create monitoring namespace
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }

  depends_on = [aws_eks_cluster.studentai_cluster]
}

# Prometheus Helm chart
resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.prometheus_chart_version
  timeout    = 600

  values = [
    yamlencode({
      prometheus = {
        prometheusSpec = {
          retention = "7d"  # Reduced retention
          # storageSpec disabled to avoid volume issues
          resources = {
            requests = {
              memory = "256Mi"  # Further reduced
              cpu    = "100m"   # Further reduced
            }
            limits = {
              memory = "512Mi"  # Further reduced
              cpu    = "250m"   # Further reduced
            }
          }
        }
        service = {
          type = "LoadBalancer"
        }
      }

      grafana = {
        enabled = false # We'll install Grafana separately
      }

      alertmanager = {
        enabled = false  # Temporarily disable AlertManager to save resources
      }

      nodeExporter = {
        enabled = true
      }

      kubeStateMetrics = {
        enabled = true
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.studentai_nodes,
    kubernetes_namespace.monitoring,
    aws_eks_cluster.studentai_cluster
  ]
}

# Grafana Helm chart
resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.grafana_chart_version

  values = [
    yamlencode({
      adminPassword = "admin123" # Change this to a secure password

      persistence = {
        enabled          = false  # Temporarily disabled to avoid volume issues
        storageClassName = "gp2"
        size             = "5Gi"  # Reduced from 10Gi
      }

      service = {
        type = "LoadBalancer"
        port = var.grafana_port
        targetPort = var.grafana_port
      }

      # Configure Grafana to run on port 8080 to avoid conflicts with StudentAI
      env = {
        GF_SERVER_HTTP_PORT = tostring(var.grafana_port)
      }

      # Configure the container port to match the server port
      containerPort = var.grafana_port

      # Fix probes to use the correct port
      livenessProbe = {
        httpGet = {
          path = "/api/health"
          port = var.grafana_port
        }
        initialDelaySeconds = 60
        timeoutSeconds = 30
        periodSeconds = 10
        successThreshold = 1
        failureThreshold = 10
      }

      readinessProbe = {
        httpGet = {
          path = "/api/health"
          port = var.grafana_port
        }
        initialDelaySeconds = 0
        timeoutSeconds = 1
        periodSeconds = 10
        successThreshold = 1
        failureThreshold = 3
      }

      resources = {
        requests = {
          memory = "128Mi"  # Further reduced
          cpu    = "100m"   # Further reduced
        }
        limits = {
          memory = "256Mi"  # Further reduced
          cpu    = "200m"   # Further reduced
        }
      }

      datasources = {
        "datasources.yaml" = {
          apiVersion = 1
          datasources = [
            {
              name      = "Prometheus"
              type      = "prometheus"
              url       = "http://prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local:9090"
              access    = "proxy"
              isDefault = true
            }
          ]
        }
      }

      dashboardProviders = {
        "dashboardproviders.yaml" = {
          apiVersion = 1
          providers = [
            {
              name            = "default"
              orgId           = 1
              folder          = ""
              type            = "file"
              disableDeletion = false
              editable        = true
              options = {
                path = "/var/lib/grafana/dashboards/default"
              }
            }
          ]
        }
      }

      dashboards = {
        default = {
          "kubernetes-cluster-monitoring" = {
            gnetId     = 7249
            revision   = 1
            datasource = "Prometheus"
          }
          "kubernetes-pod-monitoring" = {
            gnetId     = 6417
            revision   = 1
            datasource = "Prometheus"
          }
          "node-exporter-full" = {
            gnetId     = 1860
            revision   = 27
            datasource = "Prometheus"
          }
        }
      }
    })
  ]

  depends_on = [
    aws_eks_cluster.studentai_cluster,
    helm_release.prometheus,
    kubernetes_namespace.monitoring
  ]
}

# Create ingress for Grafana (optional)
resource "kubernetes_ingress_v1" "grafana_ingress" {
  count = var.domain_name != "" ? 1 : 0

  metadata {
    name      = "grafana-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = var.certificate_arn != "" ? "true" : "false"
      "cert-manager.io/cluster-issuer"           = var.certificate_arn != "" ? "letsencrypt-prod" : ""
    }
  }

  spec {
    dynamic "tls" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        hosts       = ["grafana.${var.domain_name}"]
        secret_name = "grafana-tls"
      }
    }

    rule {
      host = "grafana.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "grafana"
              port {
                number = var.grafana_port
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.grafana,
    helm_release.nginx_ingress
  ]
}

# Create ingress for Prometheus (optional)
resource "kubernetes_ingress_v1" "prometheus_ingress" {
  count = var.domain_name != "" ? 1 : 0

  metadata {
    name      = "prometheus-ingress"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"              = "nginx"
      "nginx.ingress.kubernetes.io/ssl-redirect" = var.certificate_arn != "" ? "true" : "false"
      "cert-manager.io/cluster-issuer"           = var.certificate_arn != "" ? "letsencrypt-prod" : ""
    }
  }

  spec {
    dynamic "tls" {
      for_each = var.certificate_arn != "" ? [1] : []
      content {
        hosts       = ["prometheus.${var.domain_name}"]
        secret_name = "prometheus-tls"
      }
    }

    rule {
      host = "prometheus.${var.domain_name}"
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "prometheus-kube-prometheus-prometheus"
              port {
                number = 9090
              }
            }
          }
        }
      }
    }
  }

  depends_on = [
    helm_release.prometheus,
    helm_release.nginx_ingress
  ]
}

# Data sources to get LoadBalancer information
data "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  
  depends_on = [helm_release.grafana]
}

data "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus-kube-prometheus-prometheus"
    namespace = kubernetes_namespace.monitoring.metadata[0].name
  }
  
  depends_on = [helm_release.prometheus]
}
