/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/
output "a_web_servers_public_ip_url" {
  description = "The URL to access the web server(s)"
  //value       = "http://${aws_instance.aweb_server[*].public_ip}:80"
  value       = [for ip in aws_instance.a_web_server[*].public_ip : "http://${ip}:${var.aws_tcp_80}"]
}

output "a_web_servers_public_dns_url" {
  description = "The public DNS names of the web server(s)"
  value       = aws_instance.a_web_server[*].public_dns
}

output "a_web_servers_vpc_id" {
  description = "the VPC ID of the web server(s)"
  value       = aws_instance.a_web_server[*].vpc_security_group_ids
}

output "a_web_servers_subnet_id" {
  description = "the Subnet ID of the web server(s)"
  value       = aws_instance.a_web_server[*].subnet_id
}

/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/