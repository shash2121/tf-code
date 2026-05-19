terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

data "aws_caller_identity" "current" {}

# Public Hosted Zone
resource "aws_route53_zone" "public" {
  name = var.domain_name

  dynamic "vpc" {
    for_each = var.vpc_id != "" ? [1] : []
    content {
      vpc_id = var.vpc_id
    }
  }

  tags = merge(var.tags, {
    Name        = var.domain_name
    Environment = var.environment
  })
}

# CNAME Record
resource "aws_route53_record" "cname" {
  count = var.create_cname_record ? 1 : 0

  zone_id = aws_route53_zone.public.zone_id
  name    = var.cname_record_name
  type    = "CNAME"
  ttl     = var.cname_ttl
  records = [var.cname_target]
}

# A Record - Alias to ALB
resource "aws_route53_record" "alb_alias" {
  count = var.create_alias_record ? 1 : 0

  zone_id = aws_route53_zone.public.zone_id
  name    = var.alias_record_name != "" ? "${var.alias_record_name}.${var.domain_name}" : var.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}