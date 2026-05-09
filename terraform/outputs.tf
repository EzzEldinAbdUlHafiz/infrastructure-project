output "ec2_public_ip" {
  description = "Public IP of the Flask app server — use this in your Ansible inventory"
  value = module.ec2.public_ip
}

output "rds_endpoint" {
  description = "RDS connection endpoint — paste into vault.yml as vault_db_host"
  value     = module.rds.rds_endpoint
  sensitive = true
}