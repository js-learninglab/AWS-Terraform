/*
  █████  ██     ██ ███████ 
 ██   ██ ██     ██ ██      
 ███████ ██  █  ██ ███████ 
 ██   ██ ██ ███ ██      ██ 
 ██   ██  ███ ███  ███████
*/
output "web_server_public_ip" {
  description = "The IP addresses of the web servers"
  value       = aws_instance.aweb_server[*].public_ip
}

output "web-url" {
  description = "The URL to access the web server"
  //value       = "http://${aws_instance.aweb_server[*].public_ip}:80"
  value       = [for ip in aws_instance.aweb_server[*].public_ip : "http://${ip}:80"]
}

output "public_dns" {
  description = "The public DNS names of the web servers"
  value       = aws_instance.aweb_server[*].public_dns 
}

/*
  ██████   ██████ ██████  
 ██       ██      ██   ██ 
 ██   ███ ██      ██████  
 ██    ██ ██      ██      
  ██████   ██████ ██
*/