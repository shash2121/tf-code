output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.example.private_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the EC2 instance"
  value       = aws_instance.example.public_dns
}

output "instance_arn" {
  description = "ARN of the EC2 instance"
  value       = aws_instance.example.arn
}

output "availability_zone" {
  description = "Availability zone of the EC2 instance"
  value       = aws_instance.example.availability_zone
}