output "web_sg_id" {
  description = "ID of the web server security group"
  value       = aws_security_group.web.id
}

output "rds_sg_id" {
  description = "ID of the RDS security group"
  value       = aws_security_group.rds.id
}
