resource "aws_instance" "gitlab" {
  ami                         = var.ec2_ami_id
  instance_type               = var.ec2_instance_type
  iam_instance_profile        = aws_iam_instance_profile.gitlab.name
  associate_public_ip_address = true
  subnet_id                   = var.ec2_subnet_id
  vpc_security_group_ids      = [aws_security_group.gitlab.id]
  disable_api_termination     = true

  tags = {
    "Name" = "${var.base_name}-gitlab"
  }

  root_block_device {
    volume_size = var.ec2_root_block_volume_size
    encrypted   = true
  }

  key_name = var.ec2_key_name
}

