module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "~> 18.0"
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  subnet_ids      = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  eks_managed_node_groups = {
    green = {
      desired_size            = 1
      min_size                = 1
      max_size                = 2
      instance_types          = ["t3.small"]
      create_launch_template  = false
      launch_template_name    = aws_launch_template.eks_example.name
      launch_template_version = aws_launch_template.eks_example.default_version
      iam_role_arn            = aws_iam_role.eks_node_role.arn
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

resource "aws_launch_template" "eks_example" {
  name_prefix            = "external-eks-"
  description            = "EKS managed node group external launch template"
  update_default_version = true

  network_interfaces {
    security_groups = [
      module.eks.cluster_primary_security_group_id,
      aws_security_group.node_example.id
    ]
  }
}

resource "aws_autoscaling_attachment" "eks_example" {
  autoscaling_group_name = module.eks.eks_managed_node_groups_autoscaling_group_names[0]
  lb_target_group_arn    = aws_lb_target_group.example.arn
}
