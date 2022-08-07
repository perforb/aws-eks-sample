module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  subnet_ids      = module.vpc.public_subnets

  vpc_id = module.vpc.vpc_id

  eks_managed_node_groups = {
    blue = {}
    green = {
      desired_size = 1
      min_size     = 1
      max_size     = 1

      instance_types = ["t3.small"]
      #   capacity_type  = "SPOT"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
