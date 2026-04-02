
# ============================================================================
# SpeakUp — Main Infrastructure (VPC + EKS)
# ============================================================================

# --------------------------------------------------------------------------
# Data Sources
# --------------------------------------------------------------------------
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# --------------------------------------------------------------------------
# VPC
# --------------------------------------------------------------------------
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-vpc"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in var.availability_zones : cidrsubnet(var.vpc_cidr, 4, i + 3)]

  enable_nat_gateway   = true
  single_nat_gateway   = var.environment != "production"
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Tags required for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                        = 1
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"               = 1
    "kubernetes.io/cluster/${var.cluster_name}"      = "shared"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------------------------------
# EKS Cluster
# --------------------------------------------------------------------------
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  # Public access for kubectl
  cluster_endpoint_public_access = true

  # Cluster addons
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # Managed node groups
  eks_managed_node_groups = {
    speakup_workers = {
      name           = "speakup-workers"
      instance_types = var.node_instance_types
      
      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      # Use latest AL2023 AMI
      ami_type = "AL2023_x86_64_STANDARD"

      labels = {
        role    = "worker"
        project = var.project_name
      }

      tags = {
        Project     = var.project_name
        Environment = var.environment
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# --------------------------------------------------------------------------
# EBS CSI Driver IRSA (for persistent volumes)
# --------------------------------------------------------------------------
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${var.project_name}-ebs-csi"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

# --------------------------------------------------------------------------
# Security Group for Backend API pods
# --------------------------------------------------------------------------
resource "aws_security_group" "speakup_api" {
  name_prefix = "${var.project_name}-api-"
  vpc_id      = module.vpc.vpc_id
  description = "Security group for SpeakUp API pods"

  # Allow inbound from ALB
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
    description = "API traffic from VPC"
  }

  # Allow outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name    = "${var.project_name}-api-sg"
    Project = var.project_name
  }
}
