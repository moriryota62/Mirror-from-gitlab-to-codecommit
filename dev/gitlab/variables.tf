# common parameter
variable "base_name" {
  description = "リソース群に付与する接頭語"
  type        = string
}

# module parameter
variable "ec2_ami_id" {
  description = "GitLabサーバのAMI"
  type        = string
}

variable "vpc_id" {
  description = "リソース群が属するVPCのID"
  type        = string
}

variable "ec2_instance_type" {
  description = "GitLabサーバのインスタンスタイプ"
  type        = string
}

variable "ec2_subnet_id" {
  description = "GitLabサーバを配置するパブリックサブネットのID"
  type        = string
}

variable "ec2_root_block_volume_size" {
  description = "GitLabサーバのルートデバイスの容量(GB)"
  type        = number
}

variable "ec2_key_name" {
  description = "GitLabサーバのインスタンスにsshログインするためのキーペア名"
  type        = string
  default     = null
}

variable "sg_allow_access_cidrs" {
  description = "GitLabサーバへのアクセスを許可するCIDRリスト"
  type        = list(string)
}

variable "sg_allow_vpc_cidr" {
  description = "GitLabサーバへのアクセスを許可するVPCのCIDR"
  type        = string
}

variable "cloudwatch_enable_schedule" {
  description = "GitLabサーバを自動起動/停止するか"
  type        = bool
  default     = false
}

variable "cloudwatch_start_schedule" {
  description = "GitLabサーバを自動起動する時間。時間の指定はUTCのため注意"
  type        = string
  default     = "cron(0 0 ? * MON-FRI *)"
}

variable "cloudwatch_stop_schedule" {
  description = "GitLabサーバを自動停止する時間。時間の指定はUTCのため注意"
  type        = string
  default     = "cron(0 10 ? * MON-FRI *)"
}

