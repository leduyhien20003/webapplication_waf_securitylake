# Output the Secret Manager secret key name
output "securitylake_secret_subscriber_externalID_name" {
  value = aws_secretsmanager_secret.external_id_secret.name
}

output "SQS_Splunk_id" {
  value = aws_securitylake_subscriber_notification.SQS_Splunk.id
}