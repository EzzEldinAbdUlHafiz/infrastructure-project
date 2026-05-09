variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "app_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "flask-app-server"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance (Ubuntu 22.04 or Amazon Linux 2023)"
  type        = string
}

variable "key_name" {
  description = "Name of the EC2 key pair for SSH access"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH — restrict to your IP in production"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "db_password" {
  description = "Master password for the RDS instance - set in terraform.tfvars, never hardcode"
  type        = string
  sensitive   = true
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
  default     = "t3.micro"
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