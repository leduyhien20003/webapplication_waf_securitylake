# Create cloudfront distributions
resource "aws_cloudfront_distribution" "lb_distribution" {
  origin {
    domain_name = var.load_balance_dns
    origin_id   = "ELB-${var.aws_loadb_name}"
    
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2", "TLSv1.1", "TLSv1"]
      origin_read_timeout    = 60
      origin_keepalive_timeout = 5
    }
  }
  
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution for Load Balancer"
  //default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "ELB-${var.aws_loadb_name}"

    forwarded_values {
      query_string = true
      headers      = ["Host", "Origin"]

      cookies {
        forward = "all"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = var.aws_waf_arn
# web_acl_id = aws_wafv2_web_acl.acl_cloudfront.arn
  tags = {
    Environment = "production"
  }
}