variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "environment_name" {
  description = "Name of the environment"
  type        = string
}

variable "subnet_newbits" {
  description = "Number of bits to add for subnetting"
  type        = number
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "user_data_script" {
  description = "User data script for EC2 instances"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_version" {
  description = "Version of the EKS cluster"
  type        = string
}

variable "node_group_name" {
  description = "Name of the EKS node group"
  type        = string
}

variable "node_group_instance_types" {
  description = "Instance types for EKS node group"
  type        = list(string)
}

variable "node_group_desired_size" {
  description = "Desired size of the EKS node group"
  type        = number
}

variable "node_group_min_size" {
  description = "Minimum size of the EKS node group"
  type        = number
}

variable "node_group_max_size" {
  description = "Maximum size of the EKS node group"
  type        = number
}

variable "allocated_storage" {
  description = "Allocated storage in GB for RDS instance"
  type        = number
}

variable "storage_type" {
  description = "Storage type for RDS instance"
  type        = string
}

variable "engine" {
  description = "Database engine for RDS instance"
  type        = string
}

variable "engine_version" {
  description = "Database engine version for RDS instance"
  type        = string
}

variable "instance_class" {
  description = "Instance class for RDS instance"
  type        = string
}

variable "db_name" {
  description = "Database name for RDS instance"
  type        = string
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "mydbadmin"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
  default     = "kalyandb101"
}

# Secrets Manager Variables
variable "secret_name" {
  description = "Name of the secret in Secrets Manager"
  type        = string
}

variable "secret_description" {
  description = "Description of the secret"
  type        = string
  default     = "Managed by Terraform"
}

variable "secret_string" {
  description = "Secret string to store (JSON format)"
  type        = map(string)
  sensitive   = true
}

variable "recovery_window_in_days" {
  description = "Number of days to retain the secret before deletion (0-30)"
  type        = number
  default     = 30
}

variable "force_delete" {
  description = "Force deletion without recovery window"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Whether to skip final snapshot when deleting RDS instance"
  type        = bool
}

variable "publicly_accessible" {
  description = "Whether RDS instance is publicly accessible"
  type        = bool
}

variable "backup_retention_period" {
  description = "Backup retention period for RDS instance"
  type        = number
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
}

# Route53 Variables
variable "domain_name" {
  description = "Domain name for Route53 hosted zone"
  type        = string
}

# EKS Application Deployment Variables
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

variable "app_readiness_probe_path" {
  description = "Readiness probe HTTP path (empty to disable)"
  type        = string
  default     = "/ready"
}

variable "deploy_ingress_controller" {
  description = "Whether to deploy NGINX Ingress Controller"
  type        = bool
  default     = false
}

variable "ingress_service_type" {
  description = "Service type for NGINX Ingress Controller"
  type        = string
  default     = "LoadBalancer"
}

variable "deploy_metrics_server" {
  description = "Whether to deploy metrics-server"
  type        = bool
  default     = true
}

# Redis Variables
variable "redis_identifier" {
  description = "Identifier for the Redis cluster"
  type        = string
  default     = "dev-redis"
}

variable "redis_instance_type" {
  description = "Instance type for Redis"
  type        = string
  default     = "cache.t3.small"
}

variable "redis_engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "redis_parameter_group_name" {
  description = "Parameter group name for Redis"
  type        = string
  default     = "default.redis7"
}

variable "redis_port" {
  description = "Port for Redis"
  type        = number
  default     = 6379
}

# DynamoDB Variables
variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  type        = string
  default     = "items"
}

variable "dynamodb_billing_mode" {
  description = "Billing mode for DynamoDB table"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "dynamodb_hash_key" {
  description = "Hash key for DynamoDB table"
  type        = string
  default     = "id"
}

variable "dynamodb_attributes" {
  description = "List of attribute definitions for DynamoDB"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    { name = "id",         type = "S" },
    { name = "customerId", type = "S" },
  ]
}

variable "dynamodb_global_secondary_indexes" {
  description = "List of global secondary index configurations"
  type = list(object({
    name            = string
    hash_key        = string
    range_key       = optional(string)
    projection_type = string
  }))
  default = [
    {
      name            = "idx_global_customerId"
      hash_key        = "customerId"
      projection_type = "ALL"
    }
  ]
}

# PostgreSQL RDS Variables
variable "postgres_db_identifier" {
  description = "Identifier for the PostgreSQL RDS instance"
  type        = string
  default     = "orders-postgres-db"
}

variable "postgres_allocated_storage" {
  description = "Allocated storage in GB for PostgreSQL"
  type        = number
  default     = 20
}

variable "postgres_engine" {
  description = "Engine for PostgreSQL RDS"
  type        = string
  default     = "postgres"
}

variable "postgres_engine_version" {
  description = "Engine version for PostgreSQL"
  type        = string
  default     = "16.3"
}

variable "postgres_instance_class" {
  description = "Instance class for PostgreSQL"
  type        = string
  default     = "db.t3.micro"
}

variable "postgres_db_name" {
  description = "Database name for PostgreSQL"
  type        = string
  default     = "ordersdb"
}

variable "postgres_username" {
  description = "Username for PostgreSQL"
  type        = string
  default     = "postgres"
}

variable "postgres_password" {
  description = "Password for PostgreSQL"
  type        = string
  sensitive   = true
  default     = "postgres123"
}

variable "postgres_port" {
  description = "Port for PostgreSQL"
  type        = number
  default     = 5432
}

# SQS Variables
variable "sqs_queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "dev-queue"
}

variable "sqs_fifo_queue" {
  description = "Whether to create a FIFO queue"
  type        = bool
  default     = false
}

# ArgoCD Variables
variable "deploy_argocd" {
  description = "Whether to deploy ArgoCD on the EKS cluster"
  type        = bool
  default     = false
}

variable "argocd_chart_version" {
  description = "Version of the ArgoCD Helm chart"
  type        = string
  default     = "7.3.11"
}

variable "argocd_server_service_type" {
  description = "Service type for ArgoCD server (LoadBalancer, ClusterIP, NodePort)"
  type        = string
  default     = "LoadBalancer"
}