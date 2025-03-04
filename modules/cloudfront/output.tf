# Outputs
output "cloudfront_dns" {
  description = "The domain name of the distribution"
  value = aws_cloudfront_distribution.lb_distribution.domain_name
}

output "cloudfront_id" {
  description = "The ID of the distribution"
  value = aws_cloudfront_distribution.lb_distribution.id
}

output "cloudfront_arn" {
  description = "The ARN of the distribution"
  value = aws_cloudfront_distribution.lb_distribution.arn  
}