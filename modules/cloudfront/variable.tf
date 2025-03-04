variable "region" {
  default = "ap-southeast-1"
}

variable "profile" {
  default = "mfa"
}

variable "load_balance_dns" {
  type = string
  description = "The VPC ID to ALB and Target Group"
  nullable = false
}

variable "aws_loadb_name" {
  type = string
  description = "The VPC ID to ALB and Target Group"
  nullable = false
}

variable "aws_waf_arn" {
  type = string
  description = "The waf arn to cloudfront"
  nullable = false
}