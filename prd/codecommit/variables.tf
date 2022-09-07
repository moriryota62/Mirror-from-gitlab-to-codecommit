# common parameter
variable "base_name" {
  description = "作成するリソースに付与する接頭語"
  type        = string
}

# module parameter
variable "repository_names" {
  description = "レポジトリ名のリスト"
  type        = list(string)
}

variable "incomming_ipadress" {
  description = "CodeCommitにPushしてくるパブリックIPアドレス"
  type        = string
}

variable "secureroom_ipadress" {
  description = "CodeCommitをPullするセキュアルーム端末のIPアドレス"
  type        = string
}