data "aws_iam_policy_document" "adot_collector_assume" {
  statement {
    sid = "PodIdentity"
    actions = [
      "sts:AssumeRole",
      "sts:TagSession"
    ]
    principals {
      type        = "Service"
      identifiers = ["pods.eks.amazonaws.com"]
    }
  }
}


# ADOT Collector IAM Role for Pod Identity
# IAM Role - ADOT Collector
resource "aws_iam_role" "adot_collector" {
  name = "${var.cluster_name}-adot-collector-role"
  assume_role_policy = data.aws_iam_policy_document.adot_collector_assume.json
}

# -------------------------------------------------------------------------------
# ADOT Collector IAM Policy
resource "aws_iam_policy" "adot_collector" {
  name        = "${var.cluster_name}-adot-collector-policy"
  description = "IAM policy for ADOT collector to send telemetry to CloudWatch and X-Ray"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # CloudWatch Logs Permissions (Write)
      {
        Effect = "Allow"
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*:*"
        ]
      },
      # CloudWatch Logs Permissions (Read - for querying/debugging)
      {
        Effect = "Allow"
        Action = [
          "logs:GetLogEvents",
          "logs:FilterLogEvents"
        ]
        Resource = [
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*",
          "arn:aws:logs:${var.aws_region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/*:*"
        ]
      },
      # CloudWatch Metrics Permissions
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Resource = "*"
      },
      # X-Ray Permissions
      {
        Effect = "Allow"
        Action = [
          "xray:PutTraceSegments",
          "xray:PutTelemetryRecords",
          "xray:GetSamplingRules",
          "xray:GetSamplingTargets",
          "xray:GetSamplingStatisticSummaries"
        ]
        Resource = "*"
      },
      # Amazon Managed Prometheus permissions    
      {
        Effect = "Allow"
        Action = [
          "aps:RemoteWrite",
          "aps:QueryMetrics",
          "aps:GetSeries",
          "aps:GetLabels",
          "aps:GetMetricMetadata"
        ]
        Resource = aws_prometheus_workspace.amp.arn
      }      
    ]
  })

  tags = var.tags
}

# Attach IAM Policy to IAM Role
resource "aws_iam_role_policy_attachment" "adot_collector" {
  policy_arn = aws_iam_policy.adot_collector.arn
  role       = aws_iam_role.adot_collector.name
}

# ---------------------------------------------------------------------------
# ADOT Collector Pod Identity Association
resource "aws_eks_pod_identity_association" "adot_collector" {
  depends_on = [aws_eks_node_group.node_group]
  cluster_name    = "${var.cluster_name}"
  namespace       = "default"
  service_account = "adot-collector"
  role_arn        = aws_iam_role.adot_collector.arn
  tags = var.tags
}
# -------------------------------------------------------------------------------
# Datasource: To get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "cert_manager_default" {
  addon_name         = "cert-manager"
  kubernetes_version = aws_eks_cluster.cluster.version
}

# Datasource: To get latest EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "cert_manager_latest" {
  addon_name         = "cert-manager"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

# cert-manager EKS Addon (Prerequisite for ADOT)
resource "aws_eks_addon" "cert_manager" {
  depends_on = [aws_eks_node_group.node_group]  
  cluster_name                = aws_eks_cluster.cluster.name
  addon_name                  = "cert-manager"
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  addon_version               = data.aws_eks_addon_version.cert_manager_latest.version
  tags = var.tags
}
# --------------------------------------------------------------------------------
# Datasource: To get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "adot_default" {
  addon_name         = "adot"
  kubernetes_version = aws_eks_cluster.cluster.version
}

# Datasource: To get latest EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "adot_latest" {
  addon_name         = "adot"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

# --------------------------------------------------------------------------------

# EKS Add-on: AWS Distro for OpenTelemetry (ADOT)
resource "aws_eks_addon" "adot" {
  # Cert Manager should be installed and ready before adot eks addon
  depends_on = [aws_eks_node_group.node_group,aws_eks_addon.cert_manager]  
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "adot"
  addon_version = data.aws_eks_addon_version.adot_latest.version
  
  # Configuration for the addon
  configuration_values = jsonencode({
    manager = {
      resources = {
        limits = {
          cpu    = "200m"
          memory = "256Mi"
        }
        requests = {
          cpu    = "100m"
          memory = "64Mi"
        }
      }
    }
    replicaCount = 1
  })
  
  # Conflict resolution
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = var.tags
}
# ------------------------- Prometheus node exporter Add-on ------------------------------
# Datasource: To get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "prometheus_node_exporter_default" {
  addon_name         = "prometheus-node-exporter"
  kubernetes_version = aws_eks_cluster.cluster.version
}

# Datasource: To get latest EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "prometheus_node_exporter_latest" {
  addon_name         = "prometheus-node-exporter"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

# EKS Add-on: Prometheus Node Exporter 
resource "aws_eks_addon" "prometheus_node_exporter" {
  depends_on = [aws_eks_cluster.cluster]  
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "prometheus-node-exporter"
  addon_version = data.aws_eks_addon_version.prometheus_node_exporter_latest.version  
  # Conflict resolution
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = var.tags
}

# ---------------------------- Kube State Metrics add-on -------------------------------
# Datasource: To get default EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "kube_state_metrics_default" {
  addon_name         = "kube-state-metrics"
  kubernetes_version = aws_eks_cluster.cluster.version
}

# Datasource: To get latest EKS addon version compatible with EKS cluster version
data "aws_eks_addon_version" "kube_state_metrics_latest" {
  addon_name         = "kube-state-metrics"
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

# EKS Add-on: Kube State Metrics
resource "aws_eks_addon" "kube_state_metrics" {
  depends_on = [aws_eks_cluster.cluster]    
  cluster_name  = aws_eks_cluster.cluster.name
  addon_name    = "kube-state-metrics"
  addon_version = data.aws_eks_addon_version.kube_state_metrics_latest.version  
  # Conflict resolution
  resolve_conflicts_on_create = "OVERWRITE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = var.tags
}
# --------------------------------------------------------------------------------

# ADOT Collector RBAC Resources
# Purpose: Grant OpenTelemetry Collector permissions to scrape metrics from Kubernetes API
resource "kubernetes_service_account_v1" "adot_collector" {
  metadata {
    name      = "adot-collector"
    namespace = "default"
    labels = {
      "app.kubernetes.io/name"      = "adot-collector"
      "app.kubernetes.io/component" = "opentelemetry-collector"
    }
  }
}

# Kubernetes Cluster Role
resource "kubernetes_cluster_role_v1" "otel_collector" {
  metadata {
    name = "otel-collector-cluster-role"
  }

  # Core Kubernetes resources
  rule {
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "services", "endpoints", "pods", "namespaces"]
    verbs      = ["get", "list", "watch"]
  }

  # Apps resources
  rule {
    api_groups = ["apps"]
    resources  = ["replicasets", "deployments", "daemonsets", "statefulsets"]
    verbs      = ["get", "list", "watch"]
  }

  # Extensions resources
  rule {
    api_groups = ["extensions"]
    resources  = ["ingresses"]
    verbs      = ["get", "list", "watch"]
  }

  # Metrics endpoint
  rule {
    non_resource_urls = ["/metrics"]
    verbs             = ["get"]
  }
}

# Kubernetes Cluster Role Binding
resource "kubernetes_cluster_role_binding_v1" "otel_collector" {
  metadata {
    name = "otel-collector-cluster-role-binding"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.otel_collector.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.adot_collector.metadata[0].name
    namespace = kubernetes_service_account_v1.adot_collector.metadata[0].namespace
  }
}

# --------------------------------------------------------------------------------
# --------------------------------------------------------------------------------
# Amazon Managed Service for Prometheus Workspace
resource "aws_prometheus_workspace" "amp" {
  alias = "${var.cluster_name}-amp"  
  tags = var.tags
}
# ====================
# IAM POLICIES FOR AMG
# ====================

# Policy 1: Amazon Grafana Prometheus Access Policy
resource "aws_iam_policy" "amg_prometheus_policy" {
  name        = "${var.cluster_name}-amg-prometheus-policy"
  description = "IAM policy for Grafana to access Amazon Managed Prometheus"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "aps:ListWorkspaces",
          "aps:DescribeWorkspace",
          "aps:QueryMetrics",
          "aps:GetLabels",
          "aps:GetSeries",
          "aps:GetMetricMetadata"
        ]
        Resource = "*"
      }
    ]
  })
  tags = var.tags
}

# Policy 2: Amazon Grafana SNS Policy
resource "aws_iam_policy" "amg_sns_policy" {
  name        = "${var.cluster_name}-amg-sns-policy"
  description = "IAM policy for Grafana to publish AWS SNS notifications"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "arn:aws:sns:*:${data.aws_caller_identity.current.account_id}:grafana*"
        ]
      }
    ]
  })
  tags = var.tags
}

# Policy 3: AWS X-Ray Read Only Access (AWS Managed Policy - reference only)
data "aws_iam_policy" "xray_readonly" {
  arn = "arn:aws:iam::aws:policy/AWSXrayReadOnlyAccess"
}

# IAM ROLE FOR AMG
resource "aws_iam_role" "amg_iam_role" {
  name               = "${var.cluster_name}-amg-service-role"
  description        = "IAM role for Amazon Managed Grafana"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "grafana.amazonaws.com"
        }
      },
    ]
  })
  tags = var.tags
}

# Attach Policy 1: Prometheus Access
resource "aws_iam_role_policy_attachment" "amg_prometheus_policy_attachment" {
  role       = aws_iam_role.amg_iam_role.name
  policy_arn = aws_iam_policy.amg_prometheus_policy.arn
}

# Attach Policy 2: SNS Access
resource "aws_iam_role_policy_attachment" "amg_sns_policy_attachment" {
  role       = aws_iam_role.amg_iam_role.name
  policy_arn = aws_iam_policy.amg_sns_policy.arn
}

# Attach Policy 3: X-Ray Read Only (AWS Managed)
resource "aws_iam_role_policy_attachment" "amg_xray_readonly_attachment" {
  role       = aws_iam_role.amg_iam_role.name
  policy_arn = data.aws_iam_policy.xray_readonly.arn
}
# AMAZON MANAGED GRAFANA WORKSPACE
# resource "aws_grafana_workspace" "main" {
#   depends_on = [aws_eks_cluster.cluster]    
#   name                     = "${var.cluster_name}-amg"
#   description              = "Grafana workspace for ${var.cluster_name} EKS cluster monitoring"
#   account_access_type      = "CURRENT_ACCOUNT"
#   authentication_providers = ["AWS_SSO"]  # AWS Identity Center
#   permission_type          = "CUSTOMER_MANAGED"
#   role_arn                 = aws_iam_role.amg_iam_role.arn

#   # Data sources that Grafana can query
#   data_sources = ["PROMETHEUS", "CLOUDWATCH", "XRAY"]

#   # Notification destinations
#   notification_destinations = ["SNS"]

#   # Network access: Open (as of not VPC-restricted)
#   # For VPC access, add vpc_configuration block

#   # Workspace configuration
#   configuration = jsonencode({
#     plugins = {
#       pluginAdminEnabled = true
#     }
#     unifiedAlerting = {
#       enabled = true
#     }
#   })
#   tags = var.tags
# }

# --------------------------------------------------------------------------------
