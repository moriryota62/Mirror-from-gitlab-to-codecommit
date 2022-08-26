resource "aws_security_group" "gitlab" {
  name        = "${var.base_name}-gitlab-sg"
  vpc_id      = var.vpc_id
  description = "For Gitlab EC2"

  tags = {
    "Name" = "${var.base_name}-gitlab-sg"
  }

  ingress {
    description = "Allow Access SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.sg_allow_access_cidrs
  }

  ingress {
    description = "Allow Access HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.sg_allow_access_cidrs
  }

  ingress {
    description = "Allow Access HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.sg_allow_access_cidrs
  }

  ingress {
    description = "Allow Access form VPC"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.sg_allow_vpc_cidr]
  }

  ingress {
    description = "Allow Access form VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.sg_allow_vpc_cidr]
  }

  ingress {
    description = "Allow Access form VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.sg_allow_vpc_cidr]
  }

  egress {
    description = "Allow any outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.sg_allow_vpc_cidr]
  }
}
