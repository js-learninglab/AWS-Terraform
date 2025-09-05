output "app_server_public_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = aws_instance.app_server.private_dns
}

output "db_server_private_dns" {
  value = aws_instance.db_server.private_dns
}