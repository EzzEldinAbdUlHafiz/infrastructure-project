variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS subnet group (minimum 2 for multi-AZ support)"
  type        = list(string)
}

variable "rds_sg_id" {
  description = "ID of the RDS security group (from the security_groups module)"
  type        = string
}

variable "db_name" {
  description = "Name of the PostgreSQL database to create"
  type        = string
  default     = "flaskdb"
}

variable "db_username" {
  description = "Master username for the PostgreSQL instance"
  type        = string
  default     = "flaskuser"
}

variable "db_password" {
  description = "Master password for the PostgreSQL instance — must be supplied via terraform.tfvars, never hardcoded"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}
