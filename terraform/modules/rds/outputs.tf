output "rds_endpoint" {
  description = "Connection endpoint for the RDS instance — used in Ansible vault.yml as vault_db_host"
  value       = aws_db_instance.postgres.endpoint
}

output "rds_db_name" {
  description = "Name of the PostgreSQL database"
  value       = aws_db_instance.postgres.db_name
}

output "rds_username" {
  description = "Master username for the PostgreSQL instance"
  value       = aws_db_instance.postgres.username
}
