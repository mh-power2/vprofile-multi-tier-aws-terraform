
# ==========================================
# General Configuration
# ==========================================

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

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}


# ==========================================
# Networking Configuration
# ==========================================

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "availability_zone" {
  description = "Availability Zone for the initial deployment"
  type        = string
  default     = "eu-north-1a"
}


# ==========================================
# Access Configuration
# ==========================================

variable "admin_cidr" {
  description = "Administrator public IP address in CIDR notation"
  type        = string
}

variable "ec2_key_name" {
  description = "Name of an existing AWS EC2 SSH key pair"
  type        = string
}


# ==========================================
# EC2 Configuration
# ==========================================

variable "instance_type" {
  description = "EC2 instance type for application infrastructure"
  type        = string
  default     = "t3.small"
}

variable "web_instance_count" {
  description = "Number of Nginx web server instances"
  type        = number
  default     = 1

  validation {
    condition     = var.web_instance_count >= 1 && var.web_instance_count <= 5
    error_message = "Web instance count must be between 1 and 5."
  }
}

variable "app_instance_count" {
  description = "Number of Tomcat application server instances"
  type        = number
  default     = 1

  validation {
    condition     = var.app_instance_count >= 1 && var.app_instance_count <= 5
    error_message = "Application instance count must be between 1 and 5."
  }
}


# ==========================================
# Temporary NAT Configuration
# ==========================================

variable "enable_nat_instance" {
  description = "Enable a temporary NAT instance for private subnet internet access"
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "EC2 instance type used for the NAT instance"
  type        = string
  default     = "t3.micro"
}


# ==========================================
# Resource Tags
# ==========================================

variable "common_tags" {
  description = "Common tags applied to AWS resources"
  type        = map(string)

  default = {
    Project   = "VProfile"
    ManagedBy = "Terraform"
  }
}
