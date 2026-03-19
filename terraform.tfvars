# VPC Variables
vpc_cidr         = "10.0.0.0/16"
environment_name = "dev"
subnet_newbits   = 8

# EC2 Variables
ami_id           = "ami-02b8269d5e85954ef"
instance_type    = "t2.micro"
region           = "ap-south-1"
key_name         = "dev"
user_data_script = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo chmod 777 /var/run/docker.sock
sudo apt install unzip
EOF

# EKS Variables
cluster_name              = "dev-eks-cluster"
cluster_version           = "1.31"
node_group_name           = "dev-node-group"
node_group_instance_types = ["t3.medium"]
node_group_desired_size   = 1
node_group_min_size       = 1
node_group_max_size       = 3

# Application Deployment Variables
deploy_app                = true
app_name                  = "nginx-demo"
app_namespace             = "demo"
app_replicas              = 2
app_image                 = "nginx:latest"
app_container_port        = 80
app_service_port          = 80
app_service_type          = "LoadBalancer"
deploy_ingress_controller = true
deploy_metrics_server     = true

# RDS Variables
allocated_storage       = 20
storage_type            = "gp2"
engine                  = "mysql"
engine_version          = "8.0"
instance_class          = "db.t3.micro"
db_name                 = "mydatabase"
db_username             = "mydbadmin"
db_password             = "kalyandb101"
skip_final_snapshot     = true
publicly_accessible     = false
backup_retention_period = 0

# Tags
tags = {
  Terraform = "true"
  Project   = "demo"
}

# Route53 Variables
domain_name = "infratocloud.xyz"