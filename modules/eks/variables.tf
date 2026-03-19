variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
}

variable "cluster_version" {
  description = "Kubernetes version for the EKS cluster"
  type        = string
  default     = "1.28"
}

variable "cluster_endpoint_private_access" {
  description = "Whether the Amazon EKS private API server endpoint is enabled"
  type        = bool
  default     = false
}

variable "cluster_endpoint_public_access" {
  description = "Whether the Amazon EKS public API server endpoint is enabled"
  type        = bool
  default     = true
}

variable "cluster_create_kubeconfig" {
  description = "Whether to create a kubeconfig for the cluster"
  type        = bool
  default     = true
}

variable "node_group_name" {
  description = "Name of the node group"
  type        = string
  default     = "node-group"
}

variable "node_group_instance_types" {
  description = "List of instance types for the node group"
  type        = list(string)
  default     = ["t3.medium"]
}

variable "node_group_desired_size" {
  description = "Desired number of nodes in the node group"
  type        = number
  default     = 2
}

variable "node_group_min_size" {
  description = "Minimum number of nodes in the node group"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Maximum number of nodes in the node group"
  type        = number
  default     = 3
}

variable "vpc_id" {
  description = "VPC ID where the EKS cluster will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where the EKS cluster will be deployed"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Terraform = "true"
  }
}

# Application Deployment Variables
variable "environment" {
  description = "Environment name for labeling"
  type        = string
  default     = "dev"
}

variable "deploy_app" {
  description = "Whether to deploy the application"
  type        = bool
  default     = false
}

variable "app_name" {
  description = "Name of the application"
  type        = string
  default     = "my-app"
}

variable "app_namespace" {
  description = "Kubernetes namespace for the application"
  type        = string
  default     = "default"
}

variable "app_replicas" {
  description = "Number of replicas for the application"
  type        = number
  default     = 2
}

variable "app_image" {
  description = "Docker image for the application"
  type        = string
  default     = "nginx:latest"
}

variable "app_container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "app_service_port" {
  description = "Service port"
  type        = number
  default     = 80
}

variable "app_service_type" {
  description = "Service type (ClusterIP, NodePort, LoadBalancer)"
  type        = string
  default     = "ClusterIP"
}

variable "app_cpu_limit" {
  description = "CPU limit for the application container"
  type        = string
  default     = "500m"
}

variable "app_memory_limit" {
  description = "Memory limit for the application container"
  type        = string
  default     = "512Mi"
}

variable "app_cpu_request" {
  description = "CPU request for the application container"
  type        = string
  default     = "250m"
}

variable "app_memory_request" {
  description = "Memory request for the application container"
  type        = string
  default     = "256Mi"
}

variable "app_liveness_probe_path" {
  description = "Liveness probe HTTP path (empty to disable)"
  type        = string
  default     = "/healthz"
}

variable "app_liveness_initial_delay" {
  description = "Initial delay seconds for liveness probe"
  type        = number
  default     = 30
}

variable "app_liveness_period" {
  description = "Period seconds for liveness probe"
  type        = number
  default     = 10
}

variable "app_readiness_probe_path" {
  description = "Readiness probe HTTP path (empty to disable)"
  type        = string
  default     = "/ready"
}

variable "app_readiness_initial_delay" {
  description = "Initial delay seconds for readiness probe"
  type        = number
  default     = 5
}

variable "app_readiness_period" {
  description = "Period seconds for readiness probe"
  type        = number
  default     = 10
}

# Ingress Controller Variables
variable "deploy_ingress_controller" {
  description = "Whether to deploy NGINX Ingress Controller"
  type        = bool
  default     = false
}

variable "ingress_chart_version" {
  description = "Version of the NGINX Ingress chart"
  type        = string
  default     = "4.8.3"
}

variable "ingress_service_type" {
  description = "Service type for NGINX Ingress Controller"
  type        = string
  default     = "LoadBalancer"
}

# Metrics Server Variables
variable "deploy_metrics_server" {
  description = "Whether to deploy metrics-server"
  type        = bool
  default     = true
}

variable "metrics_server_chart_version" {
  description = "Version of the metrics-server chart"
  type        = string
  default     = "3.12.0"
}