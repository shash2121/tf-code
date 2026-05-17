resource "aws_iam_policy" "AWSLoadBalancerControllerIAMPolicy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for granting permissions to AWS Load Balancer Controller"

  policy = file("/Users/shashwat/project/tf-code/modules/aws-policies/aws-load-balancer-controller-policy.json")

  tags = merge(var.tags, {
    Name = "AWSLoadBalancerControllerIAMPolicy"
  })
}

resource "aws_iam_role" "aws_load_balancer_controller" {
  name = "${var.cluster_name}-aws-load-balancer-controller-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.cluster_name}-aws-load-balancer-controller-role"
  })
}

# Attach AWS Load Balancer Controller IAM Policy
resource "aws_iam_role_policy_attachment" "aws_load_balancer_controller" {
  role       = aws_iam_role.aws_load_balancer_controller.name
  policy_arn = aws_iam_policy.AWSLoadBalancerControllerIAMPolicy.arn
}

# AWS Load Balancer Controller Helm Chart
# resource "helm_release" "aws_load_balancer_controller" {
#   name       = "aws-load-balancer-controller"
#   repository = "https://aws.github.io/eks-charts"
#   chart      = "aws-load-balancer-controller"
#   namespace  = "kube-system"

#   set {
#     name  = "clusterName"
#     value = aws_eks_cluster.cluster.name
#   }

#   set {
#     name  = "region"
#     value = var.aws_region
#   }

#   set {
#     name  = "vpcId"
#     value = var.vpc_id
#   }

#   set {
#     name  = "serviceAccount.create"
#     value = "true"
#   }

#   set {
#     name  = "serviceAccount.name"
#     value = "aws-load-balancer-controller"
#   }

#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = aws_iam_role.aws_load_balancer_controller.arn
#   }

#   depends_on = [
#     aws_iam_role.aws_load_balancer_controller
#   ]

#   lifecycle {
#     ignore_changes = [
#       # Ignore changes to chart version to avoid unnecessary updates
#       chart,
#       version,
#     ]
#   }
# }
