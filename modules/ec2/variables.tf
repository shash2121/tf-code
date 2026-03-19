variable "instance_type" {
  description = "Instance type for EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-02b8269d5e85954ef"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
  default     = "subnet-0ad1a7e33270c9834"
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs for the EC2 instance"
  type        = list(string)
  default     = ["sg-09d7a976b410774f1"]
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
  default     = "dev"
}

variable "user_data_script" {
  description = "User data script for the EC2 instance"
  type        = string
  default     = <<EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo chmod 777 /var/run/docker.sock
sudo apt install unzip
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
EOF
}