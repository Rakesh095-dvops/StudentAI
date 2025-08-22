# Create namespace for StudentAI application (ArgoCD will manage applications here)
resource "kubernetes_namespace" "studentai" {
  metadata {
    name = "studentai"
    labels = {
      name = "studentai"
    }
  }

  depends_on = [aws_eks_cluster.studentai_cluster]
}
