module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.15.1"

  cluster_name                   = local.name
  cluster_endpoint_public_access = true

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

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets

  eks_managed_node_groups = {
    prime-node = {
      min_size     = 2
      max_size     = 4
      desired_size = 2

      instance_types = ["t2.medium"]
      capacity_type  = "SPOT"

      tags = {
        ExtraTag = "prime_Node"
      }
    }
  }

  tags = local.tags
}


# Without: 
# If you don't set cluster_endpoint_public_access = true, the EKS cluster's API endpoint will be private by default.

# CoreDNS: 
# Without it, DNS resolution for Kubernetes services inside the cluster won’t work. 
# This is a crucial component for service discovery and internal communications.

# Kube-Proxy: 
# Without kube-proxy, networking between pods and services would be incomplete. 
# It is responsible for managing networking rules for services and pods in Kubernetes.

# VPC CNI: 
# Without the VPC CNI plugin, your pods will not have network connectivity using the VPC's IP addresses. 
# The VPC CNI plugin allows Kubernetes pods to receive IP addresses directly from the VPC subnet,
# which is crucial for pod communication and network routing.

# eks_managed_node_groups:
# Without: If you don't configure the node group, your EKS cluster won't have any worker nodes to run Kubernetes workloads. 
# You would either have to manually create EC2 instances and configure them as worker nodes, or use a different method 
# to provision worker nodes.
# Without a configured node group, the EKS cluster will not be able to run workloads. 
# You will also miss out on key features like node autoscaling and resource tagging.
