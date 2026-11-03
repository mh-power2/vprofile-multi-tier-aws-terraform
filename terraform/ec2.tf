
# Latest Ubuntu 22.04 LTS AMI for x86_64
data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

locals {
  servers = {
    web01 = {
      security_group_id = aws_security_group.web.id
      disk_size         = 15
    }

    app01 = {
      security_group_id = aws_security_group.app.id
      disk_size         = 25
    }

    db01 = {
      security_group_id = aws_security_group.db.id
      disk_size         = 20
    }

    mc01 = {
      security_group_id = aws_security_group.memcache.id
      disk_size         = 10
    }

    rmq01 = {
      security_group_id = aws_security_group.rabbitmq.id
      disk_size         = 15
    }
  }
}

resource "aws_instance" "servers" {
  for_each = local.servers

  ami           = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = "t3.small"

  # Temporary lab setup: direct outbound internet access.
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    each.value.security_group_id
  ]

  key_name = var.ec2_key_name

  root_block_device {
    volume_type           = "gp3"
    volume_size           = each.value.disk_size
    delete_on_termination = true
    encrypted             = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  tags = {
    Name        = "${var.project_name}-${each.key}"
    Project     = var.project_name
    Environment = "lab"
  }
}
