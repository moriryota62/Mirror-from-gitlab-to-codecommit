resource "aws_codecommit_repository" "repo" {
  for_each = toset(var.repository_names)

  repository_name = each.key
}