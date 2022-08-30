# GitLba

以下のリソースをデプロイします。

- EC2
  - EIP
  - IAM
  - SG
- CloudWatch Events (自動起動停止)
- DLM (自動バックアップ)

DLMによるスナップショットも設定します。

起動/停止のスケジュールが必要な場合、`cloudwatch_enable_schedule`をtrueに設定し、`cloudwatch_start_schedule`および`cloudwatch_stop_schedule`にcron形式でスケジュールを設定してください。なお、設定はUTCで指定します。

EC2に使用するキーペアはあらかじめ作成してください。

GitLabのAMIは[こちら](https://aws.amazon.com/marketplace/pp/prodview-w6ykryurkesjq?sr=0-1&ref_=beagle&applicationId=AWSMPContessa)で公開されているAMIです。2022/08/17時点で最新のAMIを指定しています。このAMI自体は無料ですが、サブスクライブしないと利用できません。Terraform実行前にマーケットプレイスでサブスクライブしてください。また、このAMIで作成されるGitLabのrootの初期パスワードはインスタンスIDになります。[Official GitLab releases as AMIs](https://docs.gitlab.com/ee/install/aws/#official-gitlab-releases-as-amis)

フォワードプロキシを経由してミラーさせる場合、egressのアドレスをVPC CIDR等の内部のみに修正します。プロキシだけ許可にしてしまうとSSMセッションマネージャにも繋がらくなるため、VPC　CIDRがオススメです。
