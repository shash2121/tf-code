##############################################
# ExternalDNS IAM Role (for Pod Identity)
##############################################
resource "aws_iam_role" "externaldns_role" {
  name = "${var.cluster_name}-externaldns-role"
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
}

##############################################
# Attach AWS Managed Route53 Full Access
##############################################
resource "aws_iam_role_policy_attachment" "externaldns_managed_policy" {
  role       = aws_iam_role.externaldns_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

##############################################
# ExternalDNS Pod Identity Association
##############################################
resource "aws_eks_pod_identity_association" "externaldns" {
    depends_on = [
    aws_eks_node_group.node_group
  ]  
  cluster_name    = "${var.cluster_name}"
  namespace       = "external-dns"
  service_account = "external-dns"
  role_arn        = aws_iam_role.externaldns_role.arn
}

data "aws_eks_addon_version" "externaldns_latest" {
  addon_name         = "external-dns"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

##############################################
# Install ExternalDNS Add-on
##############################################
resource "aws_eks_addon" "externaldns" {
  depends_on = [
    aws_iam_role.externaldns_role,
    aws_eks_pod_identity_association.externaldns,
    aws_eks_addon.pod_identity_agent,
    aws_eks_node_group.node_group
  ]  
  cluster_name                = "${var.cluster_name}"
  addon_name                  = "external-dns"
  addon_version               = data.aws_eks_addon_version.externaldns_latest.version

  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"

  service_account_role_arn = aws_iam_role.externaldns_role.arn

  tags = {
    Component   = "ExternalDNS"
    ManagedBy   = "Terraform"
  }
}