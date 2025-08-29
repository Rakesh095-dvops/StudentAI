# OIDC Module - OpenID Connect provider for IRSA (IAM Roles for Service Accounts)

# OpenID Connect provider for IRSA
data "tls_certificate" "eks_cluster_tls" {
  url = aws_eks_cluster.studentai_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_tls.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.studentai_cluster.identity[0].oidc[0].issuer

  # Removed tags to avoid IAM permission issues
  # tags = {
  #   Name = "${var.cluster_name}-irsa"
  # }
}
