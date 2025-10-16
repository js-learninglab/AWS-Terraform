/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/

output "app_server_private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = [for instance in aws_instance.app_server : instance.private_dns]
}

output "db_server_private_dns" {
  description = "Private DNS name of the EC2 instance."
  value       = [for instance in aws_instance.db_server : instance.private_dns]
}

output "web_server_public_ip" {
  description = "Public IP address of the EC2 instance."
  value       = [for instance in aws_instance.web_server : "http://${instance.public_ip}"]
}

/*
output "web url" {
  description = "URL of the web server."
  value       = "http://${aws_lb.web_lb.dns_name}"
}
*/
/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/