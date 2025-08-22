# Configure Kubernetes provider
provider "kubernetes" {
  host                   = aws_eks_cluster.studentai_cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.studentai_cluster.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.studentai_cluster.name, "--region", var.aws_region]
  }
}

# Configure Helm provider
provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.studentai_cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.studentai_cluster.certificate_authority[0].data)

    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.studentai_cluster.name, "--region", var.aws_region]
    }
  }
}

# Create namespace for ingress-nginx
resource "kubernetes_namespace" "ingress_nginx" {
  metadata {
    name = "ingress-nginx"
    labels = {
      name = "ingress-nginx"
    }
  }

  depends_on = [aws_eks_cluster.studentai_cluster]
}

# NGINX Ingress Controller Helm chart
resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = kubernetes_namespace.ingress_nginx.metadata[0].name
  version    = var.nginx_ingress_chart_version

  values = [
    yamlencode({
      controller = {
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"                              = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-backend-protocol"                  = "tcp"
            "service.beta.kubernetes.io/aws-load-balancer-cross-zone-load-balancing-enabled" = "true"
          }
        }

        resources = {
          limits = {
            cpu    = "1000m"
            memory = "1Gi"
          }
          requests = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }

        config = {
          "use-forwarded-headers"      = "true"
          "compute-full-forwarded-for" = "true"
          "use-proxy-protocol"         = "false"
        }

        metrics = {
          enabled = true
          serviceMonitor = {
            enabled   = true
            namespace = "monitoring"
          }
        }

        replicaCount = 2

        nodeSelector = {
          "kubernetes.io/os" = "linux"
        }

        tolerations = []

        affinity = {
          podAntiAffinity = {
            preferredDuringSchedulingIgnoredDuringExecution = [
              {
                weight = 100
                podAffinityTerm = {
                  labelSelector = {
                    matchExpressions = [
                      {
                        key      = "app.kubernetes.io/name"
                        operator = "In"
                        values   = ["ingress-nginx"]
                      }
                    ]
                  }
                  topologyKey = "kubernetes.io/hostname"
                }
              }
            ]
          }
        }
      }

      defaultBackend = {
        enabled = false
      }
    })
  ]

  depends_on = [
    aws_eks_node_group.studentai_nodes,
    kubernetes_namespace.ingress_nginx
  ]
}

# Kubernetes Service Account for Cluster Autoscaler
resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler.arn
    }
  }

  depends_on = [aws_eks_cluster.studentai_cluster]
}

# Cluster Autoscaler Deployment
resource "kubernetes_deployment" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      app = "cluster-autoscaler"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "cluster-autoscaler"
      }
    }

    template {
      metadata {
        labels = {
          app = "cluster-autoscaler"
        }
        annotations = {
          "prometheus.io/scrape" = "true"
          "prometheus.io/port"   = "8085"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.cluster_autoscaler.metadata[0].name

        container {
          image = "k8s.gcr.io/autoscaling/cluster-autoscaler:v1.27.3"
          name  = "cluster-autoscaler"

          resources {
            limits = {
              cpu    = "100m"
              memory = "300Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "300Mi"
            }
          }

          command = [
            "./cluster-autoscaler",
            "--v=4",
            "--stderrthreshold=info",
            "--cloud-provider=aws",
            "--skip-nodes-with-local-storage=false",
            "--expander=least-waste",
            "--node-group-auto-discovery=asg:tag=k8s.io/cluster-autoscaler/enabled,k8s.io/cluster-autoscaler/${aws_eks_cluster.studentai_cluster.name}",
            "--balance-similar-node-groups",
            "--skip-nodes-with-system-pods=false"
          ]

          env {
            name  = "AWS_REGION"
            value = var.aws_region
          }

          env {
            name  = "AWS_STS_REGIONAL_ENDPOINTS"
            value = "regional"
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service_account.cluster_autoscaler,
    aws_eks_node_group.studentai_nodes
  ]
}
