# Generate a random string to use as a suffix for the secret name
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

# Create the secret in AWS Secrets Manager with a dynamic name
resource "aws_secretsmanager_secret" "rds_password" {
  name        = "rds_mysql_password_${random_string.suffix.result}"
  description = "Password for the RDS instance"
}

# Generate a random password
resource "random_password" "rds_password" {
  length  = 16
  special = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~" # Exclude '/', '@', '"', and spaces
}

# Generate a random password and store it in the secret
resource "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id     = aws_secretsmanager_secret.rds_password.id
  secret_string = random_password.rds_password.result
}

# Create RDS Subnet Group to specify private subnets for Multi-AZ
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-private-subnet-group"
  subnet_ids = [var.my_rds_subnet1, var.my_rds_subnet2]

  tags = {
    Name = "RDS Private Subnet Group"
  }
}

# Create the RDS instance
resource "aws_db_instance" "mysql_rds" {
  identifier           = "myapp-mysql-rds"
  engine               = "mysql"
  engine_version       = "8.0.39"
  instance_class       = "db.t4g.micro"
  allocated_storage    = 20
  storage_type         = "gp2"

  db_name              = "myappdb"
  username             = "admin"
  password             = data.aws_secretsmanager_secret_version.rds_password_version.secret_string

  multi_az             = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = tolist(var.my_rds_sg_id)
  publicly_accessible    = false
  skip_final_snapshot    = true  # Set to false for production environments
  deletion_protection    = false  # Prevents accidental deletion

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  tags = {
    Name = "MyApp MySQL RDS"
  }
}

# Data source to retrieve the secret value
data "aws_secretsmanager_secret_version" "rds_password_version" {
  secret_id = aws_secretsmanager_secret.rds_password.id
  depends_on = [
    aws_secretsmanager_secret.rds_password,
    aws_secretsmanager_secret_version.rds_password_version
  ]
}