
# =========================================================
# 1. Retrieve Latest Ubuntu 22.04 LTS AMI
# =========================================================

data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

# =========================================================
# 2. Define Server Groups
# =========================================================

locals {

  # -------------------------------------------------------
  # Fixed Backend Servers
  # -------------------------------------------------------

  fixed_servers = {
    db01 = {
      role              = "database"
      subnet_type       = "private"
      security_group_id = aws_security_group.db.id
      disk_size         = 20
    }

    mc01 = {
      role              = "memcached"
      subnet_type       = "private"
      security_group_id = aws_security_group.memcache.id
      disk_size         = 10
    }

    rmq01 = {
      role              = "rabbitmq"
      subnet_type       = "private"
      security_group_id = aws_security_group.rabbitmq.id
      disk_size         = 15
    }
  }

  # -------------------------------------------------------
  # Scalable Web Servers
  # -------------------------------------------------------

  web_servers = {
    for index in range(var.web_instance_count) :
    "web${format("%02d", index + 1)}" => {
      role              = "web"
      subnet_type       = "public"
      security_group_id = aws_security_group.web.id
      disk_size         = 15
    }
  }

  # -------------------------------------------------------
  # Scalable Application Servers
  # -------------------------------------------------------

  app_servers = {
    for index in range(var.app_instance_count) :
    "app${format("%02d", index + 1)}" => {
      role              = "application"
      subnet_type       = "private"
      security_group_id = aws_security_group.app.id
      disk_size         = 25
    }
  }

  # -------------------------------------------------------
  # Combine All Server Groups
  # -------------------------------------------------------

  servers = merge(
    local.fixed_servers,
    local.web_servers,
    local.app_servers
  )
}

# =========================================================
# 3. Create EC2 Instances
# =========================================================

resource "aws_instance" "servers" {
  for_each = local.servers

  ami           = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.instance_type

  # Select subnet based on server role
  subnet_id = (
    each.value.subnet_type == "public"
    ? aws_subnet.public.id
    : aws_subnet.private.id
  )

  # Only web servers receive public IP addresses
  associate_public_ip_address = each.value.subnet_type == "public"

  # Attach the appropriate security group
  vpc_security_group_ids = [
    each.value.security_group_id
  ]

  # Existing AWS EC2 key pair
  key_name = var.ec2_key_name

  # -------------------------------------------------------
  # Root EBS Volume
  # -------------------------------------------------------

  root_block_device {
    volume_type           = "gp3"
    volume_size           = each.value.disk_size
    delete_on_termination = true
    encrypted             = true
  }

  # -------------------------------------------------------
  # CPU Credit Configuration
  # -------------------------------------------------------

  credit_specification {
    cpu_credits = "standard"
  }

  # -------------------------------------------------------
  # Instance Metadata Security
  # -------------------------------------------------------

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # -------------------------------------------------------
  # Resource Tags
  # -------------------------------------------------------

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-${each.key}"
    Environment = var.environment
    Role        = each.value.role
    Subnet      = each.value.subnet_type
  })
}
