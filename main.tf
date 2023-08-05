########
# Locals
########
locals {
  s3_bucket    = "${var.name}.${var.dns_zone}"
  s3_origin_id = "s3-${var.name}-${var.namespace}"
  aliases      = formatlist("%s.${var.dns_zone}", compact(var.dns_names))
}

##################
# Route53 DNS Zone
##################
data "aws_route53_zone" "this" {
  count = var.use_external_dns == false || var.private_dns == true ? 1 : 0

  name         = var.dns_zone
  private_zone = var.private_dns == true ? true : false
}


################################
# Route53 Aliases for CloudFront
################################
resource "aws_route53_record" "this" {
  count = var.use_external_dns == false || var.private_dns == true ? length(var.dns_names) : 0

  zone_id = data.aws_route53_zone.this[0].zone_id
  name    = var.dns_names[count.index]
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.this.domain_name
    zone_id                = aws_cloudfront_distribution.this.hosted_zone_id
    evaluate_target_health = false
  }
}

########################
# S3 - Static Web Assets
########################
resource "aws_s3_bucket" "this" {
  bucket = var.s3_bucket
  # acl    = "public-read"
  tags = var.tags
  # policy = data.aws_iam_policy_document.this.json

  website {
    index_document = "index.html"
    error_document = "index.html"
  }

  versioning {
    enabled = false
  }

  lifecycle {
    prevent_destroy = false
  }

  dynamic "cors_rule" {
    for_each = var.cors_rule
    content {
      allowed_headers = cors_rule.value["allowed_headers"]
      allowed_methods = cors_rule.value["allowed_methods"]
      allowed_origins = cors_rule.value["allowed_origins"]
      expose_headers  = cors_rule.value["expose_headers"]
      max_age_seconds = cors_rule.value["max_age_seconds"]
    }
  }
}

#######################################
# IAM Policy - S3 Public Website Access
#######################################
data "aws_iam_policy_document" "this" {
  statement {
    sid       = "PublicWebAccess"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.s3_bucket}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_cloudfront_origin_access_identity" "this" {
  comment = var.namespace
}

resource "aws_cloudfront_distribution" "this" {
  enabled             = true
  is_ipv6_enabled     = var.is_ipv6_enabled
  wait_for_deployment = false
  comment             = var.namespace
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  aliases             = length(local.aliases) == 0 ? [var.dns_zone] : local.aliases
  web_acl_id          = var.web_acl_id
  tags                = var.tags

  origin {
    domain_name = aws_s3_bucket.this.bucket_regional_domain_name
    origin_id   = local.s3_origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.this.cloudfront_access_identity_path
    }
  }

  # TODO setup CloudFront Access Logs
  #   logging_config {
  #     include_cookies = false
  #     bucket          = aws_s3_bucket.this
  #   }


  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    forwarded_values {
      query_string = false
      headers      = var.whitelisted_headers
      cookies {
        forward = "none"
      }
    }
  }

  custom_error_response {
    error_caching_min_ttl = 0
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }
}
