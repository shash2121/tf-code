# IAM Role for orders microservice (Pod Identity Role)
resource "aws_iam_role" "orders_postgresql_getsecrets" {
  name               = "${var.cluster_name}-orders-postgresql-getsecrets-role"
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

  tags = {
    Name        = "${var.cluster_name}-orders-dynamodb-role"
    Component   = "orders"
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "orders_postgresql_db_secret_attach" {
  policy_arn = aws_iam_policy.catalog_db_secret_policy.arn
  role       = aws_iam_role.orders_postgresql_getsecrets.name
}

# EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "orders_pod_identity" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = "default"
  service_account = "orders"
  role_arn        = aws_iam_role.orders_postgresql_getsecrets.arn
}