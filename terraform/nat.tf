
# ==========================================
# 1. NAT Security Group
# ==========================================

resource "aws_security_group" "nat" {
  count = var.enable_nat_instance ? 1 : 0

  name        = "${var.project_name}-nat-sg"
  description = "Security group for temporary NAT instance"
  vpc_id      = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nat-sg"
    Role = "NAT"
  })
}

# Allow HTTP traffic from the private subnet
resource "aws_vpc_security_group_ingress_rule" "nat_http" {
  count = var.enable_nat_instance ? 1 : 0

  security_group_id = aws_security_group.nat[0].id
  cidr_ipv4         = var.private_subnet_cidr
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"

  description = "Allow HTTP outbound requests from private subnet"
}

# Allow HTTPS traffic from the private subnet
resource "aws_vpc_security_group_ingress_rule" "nat_https" {
  count = var.enable_nat_instance ? 1 : 0

  security_group_id = aws_security_group.nat[0].id
  cidr_ipv4         = var.private_subnet_cidr
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"

  description = "Allow HTTPS outbound requests from private subnet"
}

# Allow NAT instance outbound traffic
resource "aws_vpc_security_group_egress_rule" "nat_outbound" {
  count = var.enable_nat_instance ? 1 : 0

  security_group_id = aws_security_group.nat[0].id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow outbound internet traffic"
}


# ==========================================
# 2. NAT Instance
# ==========================================

resource "aws_instance" "nat" {
  count = var.enable_nat_instance ? 1 : 0

  ami           = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type = var.nat_instance_type

  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.nat[0].id
  ]

  # NAT instances must have source/destination checking disabled
  source_dest_check = false

  # Enable encrypted root storage
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Configure IP forwarding and NAT masquerading
  user_data = <<-EOF
    #!/bin/bash
    set -eux

    apt-get update
    apt-get install -y iptables

    echo "net.ipv4.ip_forward=1" > /etc/sysctl.d/99-nat.conf
    sysctl --system

    cat > /usr/local/sbin/configure-nat.sh <<'SCRIPT'
    #!/bin/bash
    set -e

    INTERFACE=$(ip -o route show default | awk '{print $5; exit}')

    iptables -t nat -C POSTROUTING -o "$INTERFACE" -j MASQUERADE 2>/dev/null || \
      iptables -t nat -A POSTROUTING -o "$INTERFACE" -j MASQUERADE

    iptables -C FORWARD -i "$INTERFACE" -o "$INTERFACE" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
      iptables -A FORWARD -i "$INTERFACE" -o "$INTERFACE" -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    iptables -C FORWARD -i "$INTERFACE" -o "$INTERFACE" -s ${var.private_subnet_cidr} -j ACCEPT 2>/dev/null || \
      iptables -A FORWARD -i "$INTERFACE" -o "$INTERFACE" -s ${var.private_subnet_cidr} -j ACCEPT
    SCRIPT

    chmod +x /usr/local/sbin/configure-nat.sh

    cat > /etc/systemd/system/nat-config.service <<'SERVICE'
    [Unit]
    Description=Configure NAT forwarding rules
    After=network-online.target
    Wants=network-online.target

    [Service]
    Type=oneshot
    ExecStart=/usr/local/sbin/configure-nat.sh
    RemainAfterExit=yes

    [Install]
    WantedBy=multi-user.target
    SERVICE

    systemctl daemon-reload
    systemctl enable --now nat-config.service
  EOF

  tags = merge(var.common_tags, {
    Name        = "${var.project_name}-nat"
    Environment = var.environment
    Role        = "NAT"
  })
}


# ==========================================
# 3. Private Route Through NAT Instance
# ==========================================

resource "aws_route" "private_nat" {
  count = var.enable_nat_instance ? 1 : 0

  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.nat[0].id
}
