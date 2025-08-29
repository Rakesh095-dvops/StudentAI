# VPC Module - Data sources to query existing VPC details
data "aws_vpc" "existing" {
  id = var.vpc_id
}

# Private Subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = var.private_subnet_tags
  }
}

# Public Subnets  
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = var.public_subnet_tags
  }
}

# Data for individual subnets
data "aws_subnet" "private" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

data "aws_subnet" "public" {
  for_each = toset(data.aws_subnets.public.ids)
  id       = each.value
}

# Security group for EKS cluster
resource "aws_security_group" "eks_cluster_sg" {
  name_prefix = "${var.cluster_name}-cluster-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-cluster-sg"
  }
}

# EKS Cluster Security Group Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "eks_cluster_https" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  description       = "HTTPS"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = data.aws_vpc.existing.cidr_block
}

# EKS Cluster Security Group Egress Rules
resource "aws_vpc_security_group_egress_rule" "eks_cluster_all_outbound" {
  security_group_id = aws_security_group.eks_cluster_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

# Security group for EKS nodes
resource "aws_security_group" "eks_nodes_sg" {
  name_prefix = "${var.cluster_name}-nodes-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.cluster_name}-nodes-sg"
  }
}

# EKS Nodes Security Group Ingress Rules
resource "aws_vpc_security_group_ingress_rule" "eks_nodes_cluster_traffic" {
  security_group_id            = aws_security_group.eks_nodes_sg.id
  description                  = "All traffic from cluster"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.eks_cluster_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_self_communication" {
  security_group_id            = aws_security_group.eks_nodes_sg.id
  description                  = "Node to node communication"
  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.eks_nodes_sg.id
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_http" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "HTTP traffic"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_https" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "HTTPS traffic"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_auth_service" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "StudentAI Auth service port"
  from_port         = 3001
  to_port           = 3001
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_userdetails_service" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "StudentAI UserDetails service port"
  from_port         = 3002
  to_port           = 3002
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_grafana" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Grafana port"
  from_port         = 8080
  to_port           = 8080
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_prometheus" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "Prometheus port"
  from_port         = 9090
  to_port           = 9090
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "eks_nodes_nginx_ingress" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "NGINX Ingress HTTP"
  from_port         = 30000
  to_port           = 32767
  ip_protocol       = "tcp"
  cidr_ipv4         = "0.0.0.0/0"
}

# EKS Nodes Security Group Egress Rules
resource "aws_vpc_security_group_egress_rule" "eks_nodes_all_outbound" {
  security_group_id = aws_security_group.eks_nodes_sg.id
  description       = "All outbound traffic"
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}