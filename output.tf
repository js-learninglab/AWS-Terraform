/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/
output "a_web_servers1_public_ip_url" {
  description = "The URL to access the web server1"
  value       = "http://${aws_instance.a_web_server1.public_ip}:80"
}

output "a_web_servers2_public_ip_url" {
  description = "The URL to access the web server2"
  value       = "http://${aws_instance.a_web_server2.public_ip}:80"
}

output "a_web_servers1_public_dns_url" {
  description = "The public DNS names of the web server1"
  value       = aws_instance.a_web_server1.public_dns
}

output "a_web_servers2_public_dns_url" {
  description = "The public DNS names of the web server2"
  value       = aws_instance.a_web_server2.public_dns
}

output "a_web_servers1_vpc_id" {
  description = "the VPC ID of the web server1"
  value       = aws_instance.a_web_server1.vpc_security_group_ids
}

output "a_web_servers2_vpc_id" {
  description = "the VPC ID of the web server2"
  value       = aws_instance.a_web_server2.vpc_security_group_ids
}

output "a_web_servers1_subnet_id" {
  description = "the Subnet ID of the web server1"
  value       = aws_instance.a_web_server1.subnet_id
}

output "a_web_servers2_subnet_id" {
  description = "the Subnet ID of the web server2"
  value       = aws_instance.a_web_server2.subnet_id
}

output "a_web_lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.a_web_lb.dns_name
}

/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/