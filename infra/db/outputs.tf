output "db_endpoint" {
  description = "Database endpoint"
  value       = aws_db_instance.acme.address
}

output "db_port" {
  value = aws_db_instance.acme.port
}

output "db_username" {
  value = local.postgres_secret.username
}

# NOTE: Password is NOT output (must be read via Secrets Manager)
