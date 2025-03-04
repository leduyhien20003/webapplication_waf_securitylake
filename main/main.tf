terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

provider "aws" {
  region = var.region
  profile = var.account_id
}

# Create VPC
module "vpc" {
  source              = "../modules/vpc"
  region              = var.region
  availability_zones  = var.availability_zones
  cidr_block          = var.cidr_block
  public_subnet_ips   = var.public_subnet_ips
  private_subnet_ips  = var.private_subnet_ips
}

# Create Security Group
module "security" {
  source = "../modules/security"
  region = var.region
  vpc_id = module.vpc.vpc_id
}

# Create EC2 hosting web application
module "ec2" {
  source = "../modules/ec2"
  region = var.region
  instance_type = "t2.micro"
  security_groups = [
    module.security.private_security_group_id
  ]
  subnet_id1 = module.vpc.private_subnet_ids[0]
  subnet_id2 = module.vpc.private_subnet_ids[1]
}

# Create RDS using mysql hosting database
module "database"{
  source = "../modules/database"
  my_rds_subnet1 = module.vpc.private_subnet_ids[2]
  my_rds_subnet2 = module.vpc.private_subnet_ids[3]
  my_rds_sg_id = [module.security.database_security_group_id]
}

# Create Load Balance
module "load_balance" {
  source                 = "../modules/load_balance"
  region                 = var.region
  vpc_id                 = module.vpc.vpc_id
  load_balance_subnet_ids = module.vpc.public_subnet_ids
  load_balance_security_group_ids = module.security.public_security_group_id
  
  instance_id1 = module.ec2.instance_id1
  instance_id2 = module.ec2.instance_id2
}

# Create WAF
module "waf" {
  source = "../modules/waf"
}

# Create Cloudfront
module "cloudfront" { 
  source = "../modules/cloudfront"
  region = var.region
  load_balance_dns = module.load_balance.aws_loadb_dns
  aws_loadb_name = module.load_balance.aws_loadb_name
  aws_waf_arn = module.waf.waf_web_acl_arn
}

# Create securitylake
module "securitylake" {
  source = "../modules/securitylake"
  region = var.region
  account_id = var.account_id
}
