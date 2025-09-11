output "app_server_private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = [for instance in aws_instance.app_server : instance.private_dns]
}

output "db_server_private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = [for instance in aws_instance.db_server : instance.private_dns]
}