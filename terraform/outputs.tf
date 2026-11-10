
# ==========================================
# AWS Account Information
# ==========================================

output "aws_account_id" {
  description = "AWS account ID used by Terraform"
  value       = data.aws_caller_identity.current.account_id
}

output "aws_user_arn" {
  description = "Identity currently used by Terraform"
  value       = data.aws_caller_identity.current.arn
}


# ==========================================
# Network Information
# ==========================================

output "vpc_id" {
  description = "ID of the project VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}


# ==========================================
# EC2 Information
# ==========================================

output "ec2_instance_ids" {
  description = "IDs of all project EC2 instances"

  value = {
    for name, instance in aws_instance.servers :
    name => instance.id
  }
}

output "ec2_private_ips" {
  description = "Private IP addresses of all project servers"

  value = {
    for name, instance in aws_instance.servers :
    name => instance.private_ip
  }
}

output "ec2_public_ips" {
  description = "Public IP addresses of all project servers"

  value = {
    for name, instance in aws_instance.servers :
    name => instance.public_ip
  }
}
