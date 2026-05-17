variable "db_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
  default     = "my-rds-instance"
}

variable "allocated_storage" {
  description = "The allocated storage in GB for the RDS instance"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "The storage type for the RDS instance"
  type        = string
  default     = "gp2"
}

variable "engine" {
  description = "The database engine for the RDS instance"
  type        = string
  default     = "mysql"
}

variable "engine_version" {
  description = "The version of the database engine"
  type        = string
  default     = "8.0"
}

variable "instance_class" {
  description = "The instance class for the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database"
  type        = string
  default     = "mydatabase"
}

variable "username" {
  description = "The username for the database"
  type        = string
  default     = "admin"
}

variable "password" {
  description = "The password for the database"
  type        = string
  sensitive   = true
}

variable "db_subnet_group_name" {
  description = "The DB subnet group name for the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "List of VPC security group IDs to associate with the RDS instance (deprecated - security group is now created in module)"
  type        = list(string)
  default     = []
}

variable "skip_final_snapshot" {
  description = "Whether to skip taking a final snapshot when the instance is deleted"
  type        = bool
  default     = true
}

variable "publicly_accessible" {
  description = "Whether the RDS instance should be publicly accessible"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
  default     = 0
}

variable "tags" {
  description = "A map of tags to assign to the RDS instance"
  type        = map(string)
  default     = {}
}

variable "aws_region" {
  description = "AWS region where RDS is deployed"
  type        = string
  default     = "ap-south-1"
}