# VPC Variables
vpc_cidr         = "10.0.0.0/16"
environment_name = "dev"
subnet_newbits   = 8

# EC2 Variables
ami_id           = "ami-02b8269d5e85954ef"
instance_type    = "t3.small"
region           = "ap-south-1"
key_name         = "rsa-key"
user_data_script = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo chmod 777 /var/run/docker.sock
sudo apt install unzip
EOF

# EKS Variables
cluster_name              = "dev-eks-cluster"
cluster_version           = "1.35"
node_group_name           = "dev-node-group"
node_group_instance_types = ["m7i-flex.large"]
node_group_desired_size   = 1
node_group_min_size       = 1
node_group_max_size       = 3
deploy_metrics_server     = true

# RDS Variables
allocated_storage       = 20
storage_type            = "gp2"
engine                  = "mysql"
engine_version          = "8.0"
instance_class          = "db.t3.micro"
db_name                 = "shophub"
db_username             = "root"
db_password             = "password"
skip_final_snapshot     = true
publicly_accessible     = false
backup_retention_period = 0

# Secrets Manager Variables
secret_name        = "dev-rds-credentials"
secret_description = "RDS database credentials for dev environment"
secret_string = {
  MYSQL_USER     = "root"
  MYSQL_PASSWORD = "password"
}
recovery_window_in_days = 0

# Tags
tags = {
  Terraform = "true"
  Project   = "demo"
}

# Route53 Variables
domain_name = "infratocloud.xyz"

# Redis Variables
redis_identifier            = "dev-redis"
redis_instance_type         = "cache.t3.small"
redis_engine_version        = "7.0"
redis_parameter_group_name  = "default.redis7"
redis_port                  = 6379

# DynamoDB Variables
dynamodb_table_name         = "items"
dynamodb_billing_mode       = "PAY_PER_REQUEST"
dynamodb_hash_key           = "id"
dynamodb_attributes = [
  { name = "id",         type = "S" },
  { name = "customerId", type = "S" },
]
dynamodb_global_secondary_indexes = [
  {
    name            = "idx_global_customerId"
    hash_key        = "customerId"
    projection_type = "ALL"
  }
]

# PostgreSQL RDS Variables
postgres_db_identifier    = "orders-postgres-db"
postgres_allocated_storage = 20
postgres_engine           = "postgres"
postgres_engine_version   = "17.6"
postgres_instance_class   = "db.t3.micro"
postgres_db_name          = "ordersdb"
postgres_username         = "root"
postgres_password         = "password"
postgres_port             = 5432

# SQS Variables
sqs_queue_name  = "dev-orders-queue"
message_retention_seconds   = 86400