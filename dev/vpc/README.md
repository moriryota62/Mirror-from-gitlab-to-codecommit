# VPC

以下のネットワーク環境をデプロイします。サブネットの冗長数はterraform.tfvarsのsubnet_public_cidrsおよびsubnet_private_cidrsで指定する数だけ作成します。

- VPC
- サブネット (&各サブネットのルートテーブル)
  - パブリック
  - プライベート
- インターネットゲートウェイ
- NATゲートウェイ (&EIP)
- VPCエンドポイント (&各エンドポイント用のSG)
  - ssm (SSMセッションマネージャ用)
  - ec2messages (SSMセッションマネージャ用)
  - ssmmessages (SSMセッションマネージャ用)

terraform.tfvarsは環境にあわせて修正してください。
