resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "${var.environment_name}-rds-credentials"

  tags = var.tags
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    DB_USERNAME = var.db_username
    DB_PASSWORD = var.db_password
  })
}
