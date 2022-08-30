# CodeCommit

以下のリソースをデプロイします。

- CodeCommit
- IAM
  - push用ユーザー
  - pull用ユーザー

プロキシを経由しないミラーの場合、natgateway_ipadressにはミラー元のパブリックIPアドレスを設定します。たとえば、ミラー元のパブリックIPアドレスが`192.0.2.10/32`だった場合は以下のように設定します。

```
natgateway_ipadress = "192.0.2.10/32"
```
