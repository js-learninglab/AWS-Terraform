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
  value       = "http://${aws_instance.a_prom_graf_server.public_ip}:3000"
}

output "a_prometheus_url" {
  description = "The URL to access the Prometheus server"
  value       = "http://${aws_instance.a_prom_graf_server.public_ip}:9090"
}

output "a_prometheus_grafana_public_dns" {
  description = "The public DNS of the Prometheus Grafana server"
  value       = aws_instance.a_prom_graf_server.public_dns
}

output "a_rds_instance_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.a_rds_instance.endpoint
}

output "a_rds_instance_db_name" {
  description = "The database name"
  value       = aws_db_instance.a_rds_instance.db_name
}

output "a_rds_instance_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.a_rds_instance.port
}

output "a_rds_instance_master_username" {
  description = "The master username of the RDS instance"
  value       = aws_db_instance.a_rds_instance.username
}

output "a_rds_instance_secret_name" {
  description = "The name of the Secrets Manager secret for the RDS password"
  value       = aws_secretsmanager_secret.a_rds_password_secret.name
}

output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.a_ecs_repo.repository_url
}

output "ecr_repository_name" {
  description = "ECR repository name"
  value       = aws_ecr_repository.a_ecr_repo.name
}
/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/