output "hosted_zone_id" {
  description = "The ID of the Route53 hosted zone"
  value       = aws_route53_zone.public.id
}

output "hosted_zone_name_servers" {
  description = "The name servers for the hosted zone"
  value       = aws_route53_zone.public.name_servers
}

output "hosted_zone_arn" {
  description = "The ARN of the Route53 hosted zone"
  value       = aws_route53_zone.public.arn
}

output "hosted_zone_name" {
  description = "The name of the hosted zone"
  value       = aws_route53_zone.public.name
}
