output "aws_loadb_dns" {
  description = "lb dns"
  value = aws_lb.web_app_lb.dns_name
}

output "aws_loadb_name" {
  description = "lb dns name"
  value = aws_lb.web_app_lb.name
}