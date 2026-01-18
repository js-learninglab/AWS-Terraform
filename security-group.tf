# Security group
resource "aws_security_group" "a_web_sg" {
  name        = "a_web_sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  //vpc_id      = aws_vpc.a_vpc.id
  vpc_id = module.aws_vpc.vpc_id

  ingress {
    description     = "HTTP from anywhere"
    from_port       = var.aws_tcp_80
    to_port         = var.aws_tcp_80
    protocol        = var.aws_protocol_tcp
    cidr_blocks     = ["10.0.0.0/16"]
    security_groups = [aws_security_group.a_web_lb_sg.id]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = var.aws_tcp_443
    to_port     = var.aws_tcp_443
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  # removing this for now as not required
  #not liking this, seems like a backdoor
  ingress {
    description = "SSH from GitHub Actions and my IP"
    from_port   = var.aws_tcp_22
    to_port     = var.aws_tcp_22
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
    /*cidr_blocks = concat(
      var.juli_public_ip, # my public IPs
      [
        "4.175.114.0/24", # GitHub Actions
        "13.64.0.0/11",   # GitHub Actions
        "20.0.0.0/8",     # GitHub Actions (Azure)
        "40.64.0.0/10",   # GitHub Actions (Azure)
      ]
    )*/
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-sg" })
}

resource "aws_security_group" "a_web_lb_sg" {
  name        = "a_web_lb_sg"
  description = "Allow HTTP  and HTTPS inbound traffic"
  vpc_id      = module.aws_vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = var.aws_tcp_80
    to_port     = var.aws_tcp_80
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = var.aws_tcp_443
    to_port     = var.aws_tcp_443
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-lb-sg" })
}

# create security group for prometheus and grafana monitoring
resource "aws_security_group" "a_prom_graf_sg" {
  name        = "a_prom_graf_sg"
  description = "Allow HTTP and HTTPS inbound traffic"
  //vpc_id      = aws_vpc.a_vpc.id
  vpc_id = module.aws_vpc_backend.vpc_id

  ingress {
    description = "SSH from GitHub Actions and my IP"
    from_port   = var.aws_tcp_22
    to_port     = var.aws_tcp_22
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
    /*cidr_blocks = concat(
      var.juli_public_ip, # my public IPs
      [
        "4.175.114.0/24", # GitHub Actions
        "13.64.0.0/11",   # GitHub Actions
        "20.0.0.0/8",     # GitHub Actions (Azure)
        "40.64.0.0/10",   # GitHub Actions (Azure)
      ]
    )*/
  }

  ingress {
    description = "Allow Prometheus port"
    from_port   = var.aws_tcp_9090
    to_port     = var.aws_tcp_9090
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Grafana port"
    from_port   = var.aws_tcp_3000
    to_port     = var.aws_tcp_3000
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow cloudwatch exporter port"
    from_port   = var.aws_tcp_9106
    to_port     = var.aws_tcp_9106
    protocol    = var.aws_protocol_tcp
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-prom-graf-sg" })
}

resource "aws_security_group_rule" "a_prom_graf_sg_rule" {
  type                     = "ingress"
  from_port                = var.aws_tcp_9100
  to_port                  = var.aws_tcp_9100
  protocol                 = var.aws_protocol_tcp
  security_group_id        = aws_security_group.a_web_sg.id
  #source_security_group_id = aws_security_group.a_prom_graf_sg.id #need to disable this and change to cidr_blocks to allow rds access from backend vpc to frontend vpc
  cidr_blocks              = ["10.1.0.0/16"]
  description              = "Allow Prometheus to scrape node exporter metrics"
}


# create security group for RDS instance
resource "aws_security_group" "a_rds_sg" {
  name        = "a_rds_sg"
  description = "Allow inbound traffic to RDS instance"
  vpc_id      = module.aws_vpc_backend.vpc_id

  ingress {
    description = "PostgreSQL from web servers"
    from_port   = 5432
    to_port     = 5432
    protocol    = var.aws_protocol_tcp
    #security_groups = [aws_security_group.a_web_sg.id] #need to disable this and change to cidr_blocks to allow rds access from backend vpc to frontend vpc
    cidr_blocks = ["10.0.0.0/16"]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = var.aws_tcp_all
    to_port     = var.aws_tcp_all
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(local.common_tags, { Name = "${local.naming_prefix}-${var.environment}-rds-sg" })
}