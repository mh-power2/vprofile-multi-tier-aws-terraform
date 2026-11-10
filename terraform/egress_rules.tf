

# ==========================================
# Outbound Rules: Nginx Web Servers
# ==========================================

resource "aws_vpc_security_group_egress_rule" "web_outbound" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow all outbound traffic from web servers"
}


# ==========================================
# Outbound Rules: Tomcat Application Servers
# ==========================================

resource "aws_vpc_security_group_egress_rule" "app_outbound" {
  security_group_id = aws_security_group.app.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow all outbound traffic from application servers"
}


# ==========================================
# Outbound Rules: MariaDB
# ==========================================

resource "aws_vpc_security_group_egress_rule" "db_outbound" {
  security_group_id = aws_security_group.db.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow all outbound traffic from database server"
}


# ==========================================
# Outbound Rules: Memcached
# ==========================================

resource "aws_vpc_security_group_egress_rule" "memcache_outbound" {
  security_group_id = aws_security_group.memcache.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow all outbound traffic from Memcached server"
}


# ==========================================
# Outbound Rules: RabbitMQ
# ==========================================

resource "aws_vpc_security_group_egress_rule" "rabbitmq_outbound" {
  security_group_id = aws_security_group.rabbitmq.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"

  description = "Allow all outbound traffic from RabbitMQ server"
}

