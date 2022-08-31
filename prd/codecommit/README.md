# CodeCommit

以下のリソースをデプロイします。

- CodeCommit
- IAM
  - push用ユーザー
  - pull用ユーザー

terraform.tfvarsは環境にあわせて修正してください。

プロキシを経由しないミラーの場合、natgateway_ipadressにはミラー元のパブリックIPアドレスを設定します。たとえば、ミラー元のパブリックIPアドレスが`192.0.2.10/32`だった場合は以下のように設定します。

```
natgateway_ipadress = "192.0.2.10/32"
```

## Terraformデプロイ後にすること

CodeCommitモジュールで本番環境にIAMユーザーを作成した後、マネジメントコンソールでCodeCommitのHTTPS接続用のGit認証を作成します。やり方はAWSドキュメントの[Git 認証情報を使用した HTTPS ユーザーのセットアップ](https://docs.aws.amazon.com/ja_jp/codecommit/latest/userguide/setting-up-gc.html#setting-up-gc-iam)またはGitLabのドキュメントの[Set up a push mirror from GitLab to AWS CodeCommit](https://docs.gitlab.com/ee/user/project/repository/mirror/push.html#set-up-a-push-mirror-from-gitlab-to-aws-codecommit)にあります。作成した各ユーザーのUsernameとPasswordは控えておきます。

また、CodeCommitのHTTPSのクローンURLも控えておきます。
