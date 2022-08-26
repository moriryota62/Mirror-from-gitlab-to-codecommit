data "aws_region" "current" {}

resource "aws_vpc_endpoint" "ssm" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssm"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${var.base_name}-SSM-Endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ec2messages"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${var.base_name}-SSM-EC2MESSAGES-Endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ssmmessages"
  vpc_endpoint_type   = "Interface"
  vpc_id              = aws_vpc.main.id
  subnet_ids          = aws_subnet.private.*.id
  security_group_ids  = [aws_security_group.ssm_endpoint.id]
  private_dns_enabled = true

  tags = {
    "Name" = "${var.base_name}-SSM-SSMMESSAGES-Endpoint"
  }
}
