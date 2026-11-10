
# ==========================================
# Security Group: Nginx Web Servers
# ==========================================

resource "aws_security_group" "web" {
  name        = "${var.project_name}-web-sg"
  description = "Security group for Nginx web servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-web-sg"
    Role = "Web"
  }
}

# Allow public HTTP traffic
resource "aws_vpc_security_group_ingress_rule" "web_http" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  to_port           = 80
  ip_protocol       = "tcp"
  description       = "Allow HTTP traffic from the internet"
}

# Allow public HTTPS traffic
resource "aws_vpc_security_group_ingress_rule" "web_https" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  description       = "Allow HTTPS traffic from the internet"
}

# Allow SSH from administrator's public IP
resource "aws_vpc_security_group_ingress_rule" "web_ssh" {
  security_group_id = aws_security_group.web.id
  cidr_ipv4         = var.admin_cidr
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  description       = "Allow SSH from administrator IP only"
}


# ==========================================
# Security Group: Tomcat Application Servers
# ==========================================

resource "aws_security_group" "app" {
  name        = "${var.project_name}-app-sg"
  description = "Security group for Tomcat application servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-app-sg"
    Role = "Application"
  }
}

# Allow Tomcat traffic from Nginx only
resource "aws_vpc_security_group_ingress_rule" "app_tomcat" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 8080
  to_port                      = 8080
  ip_protocol                  = "tcp"
  description                  = "Allow Tomcat traffic from Nginx servers"
}

# Allow SSH from Nginx servers (bastion approach)
resource "aws_vpc_security_group_ingress_rule" "app_ssh" {
  security_group_id            = aws_security_group.app.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow SSH from web servers"
}


# ==========================================
# Security Group: MariaDB Database
# ==========================================

resource "aws_security_group" "db" {
  name        = "${var.project_name}-db-sg"
  description = "Security group for MariaDB database"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-db-sg"
    Role = "Database"
  }
}

# Allow MySQL/MariaDB traffic from application servers
resource "aws_vpc_security_group_ingress_rule" "db_mysql" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  description                  = "Allow database connections from application servers"
}

# Allow SSH from Nginx servers
resource "aws_vpc_security_group_ingress_rule" "db_ssh" {
  security_group_id            = aws_security_group.db.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow SSH from web servers"
}


# ==========================================
# Security Group: Memcached
# ==========================================

resource "aws_security_group" "memcache" {
  name        = "${var.project_name}-memcache-sg"
  description = "Security group for Memcached"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-memcache-sg"
    Role = "Cache"
  }
}

# Allow Memcached traffic from application servers
resource "aws_vpc_security_group_ingress_rule" "memcache_tcp" {
  security_group_id            = aws_security_group.memcache.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 11211
  to_port                      = 11211
  ip_protocol                  = "tcp"
  description                  = "Allow Memcached traffic from application servers"
}

# Allow SSH from Nginx servers
resource "aws_vpc_security_group_ingress_rule" "memcache_ssh" {
  security_group_id            = aws_security_group.memcache.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow SSH from web servers"
}


# ==========================================
# Security Group: RabbitMQ
# ==========================================

resource "aws_security_group" "rabbitmq" {
  name        = "${var.project_name}-rabbitmq-sg"
  description = "Security group for RabbitMQ"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rabbitmq-sg"
    Role = "MessageBroker"
  }
}

# Allow AMQP traffic from application servers
resource "aws_vpc_security_group_ingress_rule" "rabbitmq_amqp" {
  security_group_id            = aws_security_group.rabbitmq.id
  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 5672
  to_port                      = 5672
  ip_protocol                  = "tcp"
  description                  = "Allow RabbitMQ traffic from application servers"
}

# Allow SSH from Nginx servers
resource "aws_vpc_security_group_ingress_rule" "rabbitmq_ssh" {
  security_group_id            = aws_security_group.rabbitmq.id
  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  description                  = "Allow SSH from web servers"
}
