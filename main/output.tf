output "cloudfront_dns_dns" {
  value = module.cloudfront.cloudfront_dns
}

output "rds_db_endpoint" {
  value = module.database.rds_endpoint
}

output "rds_secretmanager_masterkey_name" {
  value = module.database.rds_secret_key_name
}

output "securitylake_subscriber_secretmanager_eternalID_name" {
  value = module.securitylake.securitylake_secret_subscriber_externalID_name
}

output "securitylake_SQS_Splunk_id" {
  value = module.securitylake.SQS_Splunk_id
}