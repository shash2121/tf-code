# RDS Module - Main Configuration

data "aws_caller_identity" "current" {}

# RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.db_identifier}-sg"
  description = "Security group for RDS instance ${var.db_identifier}"
  vpc_id      = var.vpc_id

  # Allow database access on configured port
  ingress {
    from_port   = var.port
    to_port     = var.port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Database access from anywhere"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.db_identifier}-rds-sg"
    }
  )
}

# RDS Instance
resource "aws_db_instance" "rds_instance" {
  identifier              = var.db_identifier
  allocated_storage       = var.allocated_storage
  storage_type            = var.storage_type
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  db_name                 = var.db_name
  username                = var.username
  password                = var.password
  port                    = var.port
  db_subnet_group_name    = var.db_subnet_group_name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = var.publicly_accessible
  backup_retention_period = var.backup_retention_period

  tags = merge(
    var.tags,
    {
      Name = "${var.db_identifier}-rds-instance"
    }
  )
}
