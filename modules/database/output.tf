# Output the RDS endpoint
output "rds_endpoint" {
  value = aws_db_instance.mysql_rds.endpoint
}

# Output the RDS instance ID
output "rds_instance_id" {
  value = aws_db_instance.mysql_rds.id
}

# Output the Secret Manager secret key name
output "rds_secret_key_name" {
  value = aws_secretsmanager_secret.rds_password.name
}