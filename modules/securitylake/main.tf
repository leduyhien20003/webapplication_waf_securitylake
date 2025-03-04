# Create an IAM role for Security Lake
resource "aws_iam_role" "security_lake_role" {
  name = "SecurityLakeRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "securitylake.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "SecurityLakeRole"
  }
}

# Attach the necessary policies to the IAM role
resource "aws_iam_role_policy_attachment" "security_lake_policy_attachment" {
  role       = aws_iam_role.security_lake_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSServiceRoleForSecurityLake"
}

# Create the Security Lake configuration
resource "aws_securitylake_data_lake" "security_lake" {
  meta_store_manager_role_arn = aws_iam_role.security_lake_role.arn
  configuration {
    region = "var.region"

    encryption_configuration {
      kms_key_id = "S3_MANAGED_KEY"
    }

    lifecycle_configuration {
      transition {
        days          = 31
        storage_class = "STANDARD_IA"
      }
      transition {
        days          = 80
        storage_class = "ONEZONE_IA"
      }
      expiration {
        days = 300
      }
    }
  }
}

resource "aws_securitylake_aws_log_source" "WAFLogs" {
  source {
    accounts    = [var.account_id]
    regions     = [var.region]
    source_name = "WAFLogs"
  }

  depends_on = [aws_securitylake_data_lake.security_lake]
}

# Generate a random string to use as a suffix for the secret name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create a secret in AWS Secrets Manager with a random 8-digit number
resource "aws_secretsmanager_secret" "external_id_secret" {
  name = "external-id-secret_${random_string.suffix.result}"
}

resource "aws_secretsmanager_secret_version" "external_id_secret_version" {
  secret_id     = aws_secretsmanager_secret.external_id_secret.id
  secret_string = format("%08d", random_integer.external_id.result)
}

# Generate a random 8-digit number
resource "random_integer" "external_id" {
  min = 10000000
  max = 99999999
}

# Retrieve the external ID from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "external_id" {
  secret_id = aws_secretsmanager_secret.external_id_secret.id
}

# Create the Security Lake subscriber for WAF 2.0
resource "aws_securitylake_subscriber" "splunk_subscriber" {
  subscriber_name = "splunk_subscriber"
  access_type     = "S3"

  source {
    aws_log_source_resource {
      source_name    = "WAF"
      source_version = "2.0"
    }
  }

  subscriber_identity {
    external_id = data.aws_secretsmanager_secret_version.external_id.secret_string
    principal   = var.account_id
  }

  depends_on = [aws_securitylake_data_lake.security_lake]
}

resource "aws_securitylake_subscriber_notification" "SQS_Splunk" {
  subscriber_id = aws_securitylake_subscriber.splunk_subscriber.id
  configuration {
    sqs_notification_configuration {}
  }
}