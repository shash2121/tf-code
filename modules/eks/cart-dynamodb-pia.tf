# IAM Policy for accessing catalog DB secret from Secrets Manager
resource "aws_iam_policy" "cart_dynamodb_policy" {
  name        = "${var.cluster_name}-cart-dynamodb-policy"
  description = "Allow Cart microservice full access to DynamoDB"

  policy = file("/Users/shashwat/project/tf-code/modules/aws-policies/cart-dynamodb-policy.json")

  tags = merge(var.tags, {
    Name = "cart-dynamodb-policy"
  })
}

# IAM Role for Cart microservice (Pod Identity Role)
resource "aws_iam_role" "cart_dynamodb_role" {
  name               = "${var.cluster_name}-cart-dynamodb-role"
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
    Name        = "${var.cluster_name}-cart-dynamodb-role"
    Component   = "Cart"
  }
}

# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "cart_dynamodb_policy_attach" {
  policy_arn = aws_iam_policy.cart_dynamodb_policy.arn
  role       = aws_iam_role.cart_dynamodb_role.name
}

# EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "cart_pod_identity" {
  cluster_name    = aws_eks_cluster.cluster.name
  namespace       = "default"
  service_account = "carts"
  role_arn        = aws_iam_role.cart_dynamodb_role.arn
}