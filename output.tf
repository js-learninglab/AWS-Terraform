/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/
output "a_web_servers_public_ip_url" {
  description = "The URL to access the web server(s)"
  value       = [for ip in aws_instance.a_web_servers[*].public_ip : "http://${ip}:80"]
}

output "a_web_servers_public_dns_url" {
  description = "The public DNS names of the web server(s)"
  value       = [for dns in aws_instance.a_web_servers[*].public_dns : "${dns}"]
}

output "a_web_servers_vpc_id" {
  description = "the VPC ID of the web server(s)"
  value       = [for vpc in aws_instance.a_web_servers[*].vpc_security_group_ids : "${vpc}"]
}
output "a_web_servers_subnet_id" {
  description = "the Subnet ID of the web server(s)"
  value       = [for subnet in aws_instance.a_web_servers[*].subnet_id : "${subnet}"]
}

output "a_web_lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.a_web_lb.dns_name
}

output "a_s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = module.aws_s3.s3_bucket_id
}

output "asg_web_lb_dns_name" {
  description = "The DNS name of the ASG load balancer"
  value       = aws_lb.asg_web_lb.dns_name
}

output "a_grafana_url" {
  description = "The URL to access the Grafana server"
  value       = "http://${aws_instance.a_prom_grafana_server.public_ip}:3000"
}

output "a_prometheus_url" {
  description = "The URL to access the Prometheus server"
  value       = "http://${aws_instance.a_prom_grafana_server.public_ip}:9090"
}

output "a_prometheus_grafana_public_dns" {
  description = "The public DNS of the Prometheus Grafana server"
  value       = aws_instance.a_prom_grafana_server.public_dns
}

/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/