output "aws_codecommit_repository_url" {
  value = [for url in aws_codecommit_repository.repo : url.clone_url_http]
}