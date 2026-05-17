# ------------------------------------ Installing CSI secrets store and AWS secrets provider ------------------------------------

data "aws_eks_cluster_auth" "cluster" {
  name = aws_eks_cluster.cluster.name
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# 1. Secrets Store CSI Driver
resource "helm_release" "csi_secrets_store" {
  name       = "csi-secrets-store"
  repository = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  chart      = "secrets-store-csi-driver"
  namespace  = "kube-system"

  # Recommended settings for production
  set {
    name  = "syncSecret.enabled"
    value = "true" # allows syncing secrets to k8s secrets
  }

  set {
    name  = "enableSecretRotation"
    value = "true" # auto-rotate secrets
  }

  depends_on = [aws_eks_addon.pod_identity_agent]
}

# 2. AWS Secrets Manager Provider
resource "helm_release" "secrets_provider_aws" {
  name       = "secrets-provider-aws"
  repository = "https://aws.github.io/secrets-store-csi-driver-provider-aws"
  chart      = "secrets-store-csi-driver-provider-aws"
  namespace  = "kube-system"

  set {
    name  = "secrets-store-csi-driver.install"
    value = "false"
  }

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    helm_release.csi_secrets_store # CSI driver must be installed first
  ]
}