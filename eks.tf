module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "19.21.0"

  cluster_name = "eks"
  cluster_version = "1.29"
  subnet_ids = module.vpc.private_subnets
  vpc_id     = module.vpc.vpc_id
  enable_irsa = true
  # create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  eks_managed_node_group_defaults = {
    disk_size = 50
    instance_types = ["t3.medium"]
  }

  eks_managed_node_groups = {
    bootstrap = {
      instance_types = ["t3.medium"]
    }
  }

  aws_auth_users = [
    {
      userarn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/cloud_user"
      groups  = ["system:masters"]
      username = "cloud_user"
    },
  ]

  aws_auth_roles = [
    {
      rolearn  = module.karpenter.role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
  ]
}

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "19.21.0"

  cluster_name = module.eks.cluster_name
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  irsa_namespace_service_accounts = ["karpenter:karpenter"]
  iam_role_arn    = module.eks.eks_managed_node_groups["bootstrap"].iam_role_arn

  enable_karpenter_instance_profile_creation = true

  # Used to attach additional IAM policies to the Karpenter node IAM role
  iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
}
