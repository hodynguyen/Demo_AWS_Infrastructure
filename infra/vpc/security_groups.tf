# -----------------------------------------
# ALB SECURITY GROUP
# -----------------------------------------
resource "aws_security_group" "alb" {
  name        = "acme-alb-sg"
  description = "Allow HTTP/HTTPS from Internet"
  vpc_id      = aws_vpc.main.id

  # Inbound: allow public access to ALB (UI + API)
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound: allow ALB to connect to UI & API services
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "acme-alb-sg"
  }
}

# -----------------------------------------
# UI SECURITY GROUP
# -----------------------------------------
resource "aws_security_group" "ui" {
  name        = "acme-ui-sg"
  description = "Allow ALB to talk to UI pods"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "Allow ALB to reach UI"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "acme-ui-sg" }
}

# -----------------------------------------
# API SECURITY GROUP
# -----------------------------------------
resource "aws_security_group" "api" {
  name        = "acme-api-sg"
  description = "Allow traffic from ALB and outbound to DB/Metrics"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Outbound: to DB
  egress {
    description     = "API calls PostgreSQL"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }

  # Outbound: to Metrics
  egress {
    description     = "Send metrics"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.metrics.id]
  }

  tags = { Name = "acme-api-sg" }
}
