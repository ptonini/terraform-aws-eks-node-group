module "role" {
  source  = "ptonini/iam-role/aws"
  version = "~> 3.0.0"
  name    = "eks-${var.cluster_name}-${var.name}"
  assume_role_policy_statements = [{
    Action = "sts:AssumeRole"
    Effect = "Allow"
    Principal = {
      Service = "ec2.amazonaws.com"
    }
  }]
  policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ]
  policy_statements = [
    {
      Action = [
        "autoscaling:DescribeAutoScalingGroups",
        "autoscaling:DescribeAutoScalingInstances",
        "autoscaling:DescribeLaunchConfigurations",
        "autoscaling:DescribeTags",
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "ec2:DescribeLaunchTemplateVersions",
        "ec2:AttachVolume",
        "ec2:CreateSnapshot",
        "ec2:CreateTags",
        "ec2:CreateVolume",
        "ec2:DeleteSnapshot",
        "ec2:DeleteTags",
        "ec2:DeleteVolume",
        "ec2:DescribeAvailabilityZones",
        "ec2:DescribeInstances",
        "ec2:DescribeSnapshots",
        "ec2:DescribeTags",
        "ec2:DescribeVolumes",
        "ec2:DescribeVolumesModifications",
        "ec2:DetachVolume",
        "ec2:ModifyVolume"
      ]
      Resource = "*"
      Effect   = "Allow"
    }
  ]
}

resource "aws_launch_template" "this" {
  key_name               = var.ssh_key
  user_data              = var.user_data
  vpc_security_group_ids = var.vpc_security_group_ids
  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name = "${var.cluster_name}-${var.name}"
    }, var.tags)
  }
}

resource "aws_eks_node_group" "this" {
  cluster_name    = var.cluster_name
  node_group_name = var.name
  node_role_arn   = module.role.this.arn
  subnet_ids      = var.subnet_ids
  instance_types = [
    var.instance_type
  ]
  labels = var.labels

  dynamic "taint" {
    for_each = var.taints

    content {
      effect = taint.value.effect
      key    = taint.value.key
    }
  }

  scaling_config {
    desired_size = var.desired_size
    max_size     = coalesce(var.max_size, var.desired_size)
    min_size     = coalesce(var.min_size, var.desired_size)
  }

  launch_template {
    version = aws_launch_template.this.latest_version
    id      = aws_launch_template.this.id
  }

  lifecycle {
    ignore_changes = [
      # scaling_config.0.desired_size
    ]
  }
}
