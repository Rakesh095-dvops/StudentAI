# EKS Module - EKS Cluster and Node Group Configuration

# EKS Cluster
resource "aws_eks_cluster" "studentai_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(data.aws_subnets.private.ids, data.aws_subnets.public.ids)
    security_group_ids      = [aws_security_group.eks_cluster_sg.id]
    endpoint_private_access = true
    endpoint_public_access  = true
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]

  tags = {
    Name = var.cluster_name
  }
}

# EKS Node Group
resource "aws_eks_node_group" "studentai_nodes" {
  cluster_name    = aws_eks_cluster.studentai_cluster.name
  node_group_name = "${var.cluster_name}-nodes"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = data.aws_subnets.public.ids

  capacity_type  = var.node_capacity_type
  instance_types = var.node_instance_types

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy,
  ]

  tags = {
    Name                                                                  = "${var.cluster_name}-nodes"
    "k8s.io/cluster-autoscaler/enabled"                                   = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.studentai_cluster.name}" = "owned"
  }
}

# EKS add-ons
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = aws_eks_cluster.studentai_cluster.name
  addon_name   = "vpc-cni"

  depends_on = [aws_eks_node_group.studentai_nodes]
}

resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.studentai_cluster.name
  addon_name   = "coredns"

  depends_on = [aws_eks_node_group.studentai_nodes]
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.studentai_cluster.name
  addon_name   = "kube-proxy"

  depends_on = [aws_eks_node_group.studentai_nodes]
}

resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = aws_eks_cluster.studentai_cluster.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  depends_on = [
    aws_eks_node_group.studentai_nodes,
    aws_iam_role_policy_attachment.ebs_csi_driver
  ]
}
