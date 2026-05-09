variable "ami_id" {
  description = "AMI for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "Instance type for the EC2 instance"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the EC2 instance"
  type        = string
}

variable "security_group_ids" {
  description = "Security group IDs for the EC2 instance"
  type        = list(string)
}

variable "key_name" {
  description = "Key pair name for the EC2 instance"
  type        = string
}

variable "instance_name" {
  description = "Name for the EC2 instance"
  type        = string
}

variable "environment" {
  description = "Environment for the EC2 instance"
  type        = string
}
