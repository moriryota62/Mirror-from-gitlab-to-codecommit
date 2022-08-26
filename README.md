# Mirror from gitlab to codecommit

セキュリティの厳しいシステムの場合、本番環境へのアクセスを物理的に隔離された場所からのみに制限することがあります。この隔離環境は物理的だけでなく、ネットワーク的にもインバウンド/アウトバウンドの制限がされています。そのため、この隔離環境にデータを持ち運ぶのは大変です。

IaCでシステムを運用する場合、コードをこの隔離環境に連携する必要があります。多くの場合、IaCのコードはGitで管理されているはずです。隔離環境でなければ端末からGitリポジトリをpullすればよいですが、隔離環境の端末からGitリポジトリに直接できてしまうと問題もあります。たとえば、隔離環境の端末からGitリポジトリへのアウトバウンドを許可し、pullしかできないGitのユーザーを用意したとしましょう。一見問題ない様に思えますが、端末側の設定を変更してpushもできるユーザーになってしまえば本番環境のデータをGitにpushできてしまいます。このように、本番環境のデータを簡単に持ち出せてしまう仕組みは隔離環境に好ましくありません。

そこでGitリポジトリのコードを安全に隔離環境へ連携する方法を紹介します。ここで言う安全とはGitリポジトリから隔離環境へデータを送ることができますが、隔離環境からデータを外部に送れない仕組みのことです。また、この仕組の良いところは連携する時に複雑な手順を必要としない点です。git pushまたはgit pullを行うだけで簡単にデータを送ることができます。

なお、今回紹介する方法はAWSを前提としています。

# 全体像

AWSは開発用アカウントと本番用アカウントの2環境あります。コードを管理するGitリポジトリは開発環境にセルフホストのGitLabを建てます。開発環境のGitLabには作業端末は直接アクセス可能です。セキュリティ対策のため、開発環境からのアウトバウンドはフォワードプロキシで制限します。本番環境にはCodeCommitを作成します。CodeCommitにアクセスする専用のIAMユーザーを本番環境に作成します。IAMユーザーはミラー用と隔離環境用の2種類作成します。ミラー用ユーザーはpushを行えますが、隔離環境用ユーザーはpullのみを許可します。開発環境のGitLabから本番環境のCodeCommitへリポジトリのミラーリングを行いデータを連携します。ミラーはミラー用ユーザーの認証情報を使用します。最後に、本番環境にアクセス可能な隔離環境の端末から隔離環境用ユーザーでpullします。これで外部からデータを取得できますが、外部に送ることはできない仕組みになります。

絵

## GitLab

普段の開発で使用しているGitLabです。ソースの管理はこのGitLabで一元管理します。このGitLabインスンタンスに付与するSecurityGroupはインバウンド/アウトバウンドともに制限を設けます。インバウンドは作業端末からのIPアドレスのみを許可します。アウトバウンドはVPC内部のみ許可します。セキュリティ対策のため、直接インターネットへ出ることは禁止しフォワードプロキシを経由するようにします。

## フォワードプロキシ

VPCからインターネットへ出る前段にフォワードプロキシを建て、アウトバウンドを制限します。宛先のURLはホワイトリストで許可します。ミラーに必要なのはCodeCommitのエンドポイントであるため、`.amazonaws.com`などを許可すれば良いです。インターネットへ出る経路は GitLab -> フォワードプロキシ -> NAT Gateway となります。そのため、本番環境のCodeCommitへアクセスする際のソースIPはNAT Gatewayになります。

> 本当はフォワードプロキシを建てず、CodeCommitのVPCエンドポイントをVPCに作成する方法を採りたかったです。これならインターネットを経由しないでミラーできます。しかし、この方法だとミラー用ユーザーのソースIPの絞り込みができませんでした。具体的にはVPCエンドポイント経由でミラーした際のソースIPをCloudTrailで確認するとVpcSourceIpがAWS Internalと表示され、絞り込めませんでした。他にもSourceVpc等でしぼれないか試しましたかそれも駄目でした。ソースIPの絞り込みができないと、例えば隔離端末からミラー用ユーザーを使い本番データをpushすることができてしまいます。これを防ぐためソースIPの絞り込みができるインターネット経由でのミラーニングを採用しました。もしVPCエンドポイント経由で絞り込む方法を知っていれば教えてほしいです。

## CodeCommit

本番環境にCodeCommitのリポジトリを作成します。また、CodeCommitにアクセスする専用のIAMユーザーも作成します。IAMユーザーはミラー用と端末用の2つ作成します。ミラー用のユーザーにはGitLabからリポジトリをミラーするのに必要な権限を与え、アクセス元のソースIPを開発環境のNAT Gatewayに限定します。これでCodeCommitへのpushは開発環境からのみ可能となり、本番環境および隔離環境からはpushできません。端末用のユーザーはpullに必要な権限を与え、アクセス元のソースIPを隔離環境の端末に限定します。

# Terraform

本リポジトリには以下のコード群を含みます。

- 開発環境用
  - VPC  VPC、サブネット、インターネットゲートウェイ、NATゲートウェイを作成します。
  - GitLab  セルフホストのGitLabを作成します。
- 本番環境用
  - CodeCommit  リポジトリ、IAMユーザー(push用/pull用)を作成します。

フォワードプロキシのコードは含まれていません。

# 構築手順

以下の順で構築します。3と4はフォワードプロキシを設定する場合のみ実施します。

## 1. terraform実行

以下のterraformを実行してください。自身の環境に合わせてterraform.tfvarsを修正してください。既存のリソースを使用する場合は実行しなくても良いです。

- dev/vpc
- dev/gitlab
- prd/codecommit

なお、`prd/codecommit`に関しては注意があります。フォワードプロキシを使用する場合、開発環境のNATゲートウェイのIPアドレスを指定してください。フォワードプロキシを使用しない場合、GitLabのパブリックIPを指定してください。



## 2. CodeCommitユーザーの認証情報

IAMユーザーを作成した後、マネジメントコンソールでCodeCommitのHTTPS接続用のGit認証を作成します。やり方はAWSドキュメントの[Git 認証情報を使用した HTTPS ユーザーのセットアップ](https://docs.aws.amazon.com/ja_jp/codecommit/latest/userguide/setting-up-gc.html#setting-up-gc-iam)またはGitLabのドキュメントの[Set up a push mirror from GitLab to AWS CodeCommit](https://docs.gitlab.com/ee/user/project/repository/mirror/push.html#set-up-a-push-mirror-from-gitlab-to-aws-codecommit)にあります。作成した各ユーザーのUsernameとPasswordは控えておきます。

## 3. フォワードプロキシ作成

フォワードプロキシを使用しない場合は飛ばしてください。

AWSにフォワードプロキシを作成する方法は多々ありますが、私の環境にはEKSがあるためEKS Fargateでフォワードプロキシを構築します。詳しいやり方はこちらの[]()を参照ください。

## 4. GitLabにプロキシ設定

フォワードプロキシを使用しない場合は飛ばしてください。

GitLabにフォワードプロキシを設定する方法はこちらの[Setting custom environment variables](https://docs.gitlab.com/omnibus/settings/environment-variables.html)が参考になります。ミラーの場合、gitalyにプロキシを設定します。
たとえば以下の様に/etc/gitlab/gitlab.rbを設定します。http_proxyおよびhttps_proxyの指定先は構築するフォワードプロキシです。

```
gitaly['env'] = {
    "http_proxy" => "http://k8s-kubesyst-squid-f7f22160e9-214904599b63299c.elb.ap-northeast-1.amazonaws.com:3128",
    "https_proxy" => "http://k8s-kubesyst-squid-f7f22160e9-214904599b63299c.elb.ap-northeast-1.amazonaws.com:3128"
}
```

設定したらGitLabを再構成します。一応、GitLabを停止して再度起動します。

```
gitlab-ctl stop
gitlab-ctl reconfigure
gitlab-ctl start
```

## 5. GitLabのリポジトリでミラー設定



```
http://ec2-3-6-112-173.ap-south-1.compute.amazonaws.com/projects/new
```

GitLabのリポジトリでミラーを設定します。設定方法はGitLabドキュメントの[Set up a push mirror from GitLab to AWS CodeCommit](https://docs.gitlab.com/ee/user/project/repository/mirror/push.html#set-up-a-push-mirror-from-gitlab-to-aws-codecommit)にあります。

以下のようにpushミラーの設定をします。URLにはCodeCommitのURLに本番環境で作成したミラー用ユーザーの認証情報を加えます。

```
URL: 
```

## 6. 隔離端末からCodeCommitをクローン

隔離端末からCodeCommitのリポジトリをクローンします。マネジメントコンソール等でCodeCommitのHTTPSクローンURLを確認しクローンします。ユーザーとパスワードは本番環境で作成した隔離端末用ユーザーの認証情報を指定します。


## 7. 動作確認

1. 作業端末から開発環境のGitLabに修正を加えます。
2. 隔離端末から本番環境のCodeCommitをpullし、変更が反映されていることを確認します。
