
variable "aws_region" {
  description = "AWS region where infrastructure will be deployed"
  type        = string
  default     = "eu-north-1"
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "vprofile-aws"
}

variable "admin_cidr" {
  description = "Your public IP address allowed to access SSH"
  type        = string
}

variable "ec2_key_name" {
  description = "Name of an existing AWS EC2 SSH key pair"
  type        = string
}