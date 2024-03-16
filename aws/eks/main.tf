locals {
  cluster_name = "us-north-1-sandbox-1-eks"
}

data "aws_vpc" "cluster_vpc" {
  tags = {
    Name = "eu-north-1-demo-zpq-vpc"
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.cluster_vpc.id]
  }
  tags = {
    Tier = "private"
  }
}
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.3"

  cluster_name                             = local.cluster_name
  cluster_version                          = "1.29"
  vpc_id                                   = data.aws_vpc.cluster_vpc.id
  subnet_ids                               = data.aws_subnets.private.ids
  enable_cluster_creator_admin_permissions = true
  cluster_endpoint_public_access           = true
  tags                                     = {
    Name = "us-north-1-sandbox-1-eks"
  }
  cluster_tags = {
    Name = "us-north-1-sandbox-1-eks"
  }

  enable_irsa = true

  cluster_enabled_log_types              = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  cloudwatch_log_group_retention_in_days = 90

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
  }

  eks_managed_node_group_defaults = {
    ami_type             = "AL2_x86_64"
    platform             = "linux"
    disk_size            = "50"
    force_update_version = true
    enable_monitoring    = true
    tags                 = {
      Name = "${local.cluster_name}-ng"
    }
    iam_role_tags = {
      Name = "${local.cluster_name}-ng-iam-role"
    }
    launch_template_tags = {
      Name = "${local.cluster_name}-ng-launch-template"
    }
    security_group_tags = {
      Name = "${local.cluster_name}-ng-sg"
    }
  }

  eks_managed_node_groups = {
    group_a = {
      capacity_type  = "ON_DEMAND",
      desired_size   = "1"
      max_size       = "100"
      min_size       = "1"
      instance_types = [
        "m5.xlarge"
      ]
      key_name = ""
      labels   = {
        env = local.cluster_name
      }
      tags = {
        "cluster" = local.cluster_name
      }
    }
  }
}


