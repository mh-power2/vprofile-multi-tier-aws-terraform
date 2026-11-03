
# Security Group: Nginx
resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for Nginx web server"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-web-sg"
  }
}

# HTTP
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
}

# HTTPS
resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
}

# SSH from your IP only
resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.admin_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
}


# Security Group: Tomcat
resource "aws_security_group" "app" {
  name   = "${var.project_name}-app-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# Tomcat traffic from Nginx only
resource "aws_vpc_security_group_ingress_rule" "app_tomcat" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
}

# SSH from web server (temporary bastion approach)
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}


# Security Group: MariaDB
resource "aws_security_group" "db" {
  name   = "${var.project_name}-db-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}


# Security Group: Memcached
resource "aws_security_group" "memcache" {
  name   = "${var.project_name}-memcache-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-memcache-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "memcache_tcp" {
  security_group_id            = aws_security_group.memcache.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 11211
  to_port                      = 11211
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "memcache_ssh" {
  security_group_id            = aws_security_group.memcache.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}


# Security Group: RabbitMQ
resource "aws_security_group" "rabbitmq" {
  name   = "${var.project_name}-rabbitmq-sg"
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rabbitmq-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "rabbitmq_amqp" {
  security_group_id            = aws_security_group.rabbitmq.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5672
  to_port                      = 5672
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rabbitmq_ssh" {
  security_group_id            = aws_security_group.rabbitmq.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
}
