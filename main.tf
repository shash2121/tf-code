terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.20"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.10"
    }
  }
}

provider "aws" {
  region = var.region
}

# Secrets Manager Module - Store RDS credentials
module "secrets_manager" {
  source                  = "./modules/secrets-manager"
  secret_name             = var.secret_name
  description             = var.secret_description
  secret_string           = var.secret_string
  recovery_window_in_days = var.recovery_window_in_days
  tags                    = var.tags
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = var.vpc_cidr
  environment_name = var.environment_name
  aws_region       = var.region
  tags             = var.tags
  subnet_newbits   = var.subnet_newbits
  cluster_name     = var.cluster_name
}

# EC2 Security Group Module
module "ec2_security_group" {
  source              = "./modules/security-group"
  security_group_name = "${var.environment_name}-ec2-sg"
  description         = "Security group for EC2 instance with SSH access"
  vpc_id              = module.vpc.vpc_id
  ingress_rules = {
    ssh = {
      description = "SSH access from anywhere"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  }
  tags = var.tags
}

module "ec2" {
  source                 = "./modules/ec2"
  ami_id                 = var.ami_id
  instance_type          = var.instance_type
  region                 = var.region
  subnet_id              = module.vpc.public_subnet_ids[0] # Using first public subnet
  vpc_security_group_ids = [module.ec2_security_group.security_group_id]
  key_name               = var.key_name
  user_data_script       = var.user_data_script
}

module "eks" {
  source                    = "./modules/eks"
  cluster_name              = var.cluster_name
  cluster_version           = var.cluster_version
  node_group_name           = var.node_group_name
  node_group_instance_types = var.node_group_instance_types
  node_group_desired_size   = var.node_group_desired_size
  node_group_min_size       = var.node_group_min_size
  node_group_max_size       = var.node_group_max_size
  vpc_id                    = module.vpc.vpc_id
  subnet_ids                = module.vpc.public_subnet_ids
  tags                      = var.tags
  aws_region                = var.region

  # Metrics Server
  deploy_metrics_server = var.deploy_metrics_server
}

# Route53 Module - Public Hosted Zone
module "route53" {
  source      = "./modules/route53"
  domain_name = var.domain_name
  environment              = var.environment_name
  tags                     = var.tags
}

# ACM Module - SSL/TLS Certificate with DNS validation
module "acm" {
  source                    = "./modules/acm"
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  zone_id                  = module.route53.hosted_zone_id
  environment              = var.environment_name
  tags                     = var.tags
}

# RDS Module
module "rds" {
  source                  = "./modules/rds"
  db_identifier           = "${var.environment_name}-rds-instance"
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = module.vpc.db_subnet_group_name # Using VPC's DB subnet group
  vpc_id                  = module.vpc.vpc_id               # VPC ID for security group
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  tags                    = var.tags
}

# PostgreSQL RDS Module
module "postgres_rds" {
  source                  = "./modules/rds"
  db_identifier           = var.postgres_db_identifier
  allocated_storage       = var.postgres_allocated_storage
  storage_type            = var.storage_type
  engine                  = var.postgres_engine
  engine_version          = var.postgres_engine_version
  instance_class          = var.postgres_instance_class
  db_name                 = var.postgres_db_name
  username                = var.postgres_username
  password                = var.postgres_password
  port                    = var.postgres_port
  db_subnet_group_name    = module.vpc.db_subnet_group_name
  vpc_id                  = module.vpc.vpc_id
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period
  tags                    = var.tags
}

# Redis Module
module "redis" {
  source                   = "./modules/redis"
  redis_identifier         = var.redis_identifier
  instance_type            = var.redis_instance_type
  engine_version           = var.redis_engine_version
  parameter_group_name     = var.redis_parameter_group_name
  port                     = var.redis_port
  subnet_ids               = module.vpc.private_subnet_ids
  vpc_id                   = module.vpc.vpc_id
  allowed_cidr_blocks      = [var.vpc_cidr]
  environment              = var.environment_name
  tags                     = var.tags
}

# DynamoDB Module
module "dynamodb" {
  source       = "./modules/dynamodb"
  table_name   = var.dynamodb_table_name
  billing_mode = var.dynamodb_billing_mode
  hash_key     = var.dynamodb_hash_key
  attributes   = var.dynamodb_attributes
  global_secondary_indexes = var.dynamodb_global_secondary_indexes
  tags         = var.tags
}

# SQS Module
module "sqs" {
  source      = "./modules/sqs"
  queue_name  = var.sqs_queue_name
  fifo_queue  = var.sqs_fifo_queue
  tags        = var.tags
}