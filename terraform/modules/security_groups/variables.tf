variable "vpc_id" {
  description = "ID of the VPC where security groups will be created"
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g. dev, staging, prod)"
  type        = string
  default     = "prod"
}

variable "ssh_allowed_cidrs" {
  description = "List of CIDR blocks allowed to SSH into the web server. Restrict to your IP in production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
