resource "aws_eip" "gitlab" {
  instance = aws_instance.gitlab.id
  vpc      = true

  tags = {
    "Name" = "${var.base_name}-gitlab-eip"
  }
}