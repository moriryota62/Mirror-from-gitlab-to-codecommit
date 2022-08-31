# Mirror from gitlab to codecommit

個人情報等をあつかうセキュリティの厳しいシステムの場合、本番環境へのアクセスを物理的に隔離された場所からのみに制限することがあります。この隔離環境は物理的だけでなくネットワーク的にもインバウンド/アウトバウンドの制限がされています。これにより隔離環境からデータを持ち出すことを難しくしています。同時に隔離環境へデータを持ち運ぶのも手間がかかります。

IaCでシステムを運用する場合、コードを隔離環境に連携する必要があります。多くの場合、IaCのコードはGitで管理されているはずです。隔離環境でなければ端末からGitリポジトリをpullすればよいですが、隔離環境の端末から普段開発に使っているGitリポジトリに直接アクセスできてしまうと問題もあります。たとえば隔離環境の端末からpullしかできないユーザーを使い運用していくことを考えます。一見問題ない様に思えますが、Gitリポジトリに直接アクセスできるため、pushもできるユーザーに切り替えてしまえば隔離環境からデータを持ち出せてしまいます。このように、データを持ち出せてしまう仕組みは隔離環境に好ましくありません。

そこで隔離環境からはデータを持ち出せず、Gitリポジトリのコードを安全に隔離環境へ連携する方法を紹介します。この仕組は隔離環境へデータを起こることはできますが、隔離環境からデータを持ち出せません。操作もgit pushまたはgit pullだけで簡単です。

なお、今回紹介する方法はAWSを前提としています。

# 全体像

AWSは開発用アカウントと本番用アカウントの2つあります。開発環境にはコードを管理するGitリポジトリをセルフホストGitLabで建てます。このGitLabに対するインバウンドは作業端末のみを許可し、インターネットへのアウトバウンドはフォワードプロキシで制御します。本番環境にはCodeCommitを作成します。CodeCommitにアクセスする専用のIAMユーザーを作成します。IAMユーザーはpush用とpull用の2種類を作成します。開発環境のGitLabから本番環境のCodeCommitへリポジトリのミラーリングを行います。ミラーはpush用ユーザーを使用して行います。最後に、隔離環境の端末からpull用ユーザーでpullします。

このように、この仕組の肝は開発用のGitリポジトリと隔離環境用のGitリポジトリを別々で作成し、リポジトリのミラーリングで連携する点です。今回は セフルホストGitLab -> CodeCommit で連携させましたが他のGitリポジトリの組み合わせでも似たようなことはできると思います。

![全体像](./git-mirror.svg)

## 作業端末

普段の開発で使用する端末です。開発用のGitLabにもアクセスできます。本番環境のCodeCommitにはアクセスできません。

## GitLab

普段の開発で使用するGitLabです。コードの管理はこのGitLabで行います。このGitLabはインバウンドおよびアウトバウンドの通信を行います。

インバウンドの通信は普段の開発で行うGitの操作です。そのため、SecurityGroupのインバウンドは作業端末からのIPアドレスのみを許可します。

アウトバウンドはリポジトリのミラーで使用します。ミラーはインターネットのCodeCommitエンドポイントに通信します。インターネットへのアウトバウンドを絞りたい場合、フォワードプロキシを経由させます。SecurityGroupのアウトバウンドはVPC内部を許可します。GitLabにはプロキシの設定を行い、フォワードプロキシでURLのフィルタリングを行います。

隔離環境へ連携したいリポジトリにはリポジトリのミラー設定を行います。ミラーには本番環境のCodeCommit URLとpush用ユーザーの認証情報を使って設定します。

> 本当はフォワードプロキシを建てず、CodeCommitのVPCエンドポイントを経由する方法を採りたかったです。これならインターネットを経由しないでミラーできるため、フォワードプロキシも不要です。しかし、この方法だとミラーは可能ですが、push用ユーザーのソースIPの絞り込みができませんでした。具体的にはVPCエンドポイント経由でミラーした際のソースIPをCloudTrailで確認するとVpcSourceIpがAWS Internalと表示され、絞り込めませんでした。他にもSourceVpc等で絞れないか試しましたかそれも駄目でした。ソースIPの絞り込みができないと、例えば隔離端末からpush用ユーザーを使い本番データをpushすることができてしまい問題です。これを防ぐためソースIPの絞り込みができるインターネット経由でのミラーニングを採用しました。もしVPCエンドポイント経由で絞り込む方法があればその方がいいです。

## フォワードプロキシ

GitLabからのアウトバウンドを絞りたい場合、フォワードプロキシを建ててアウトバウンドを制限します。URLはホワイトリストで許可します。ミラーに必要なのはCodeCommitのエンドポイントであるため、`.amazonaws.com`などを許可すれば良いです。なお、フォワードプロキシを使う場合、GitLabからCodeCommitへ接続する経路は GitLab -> フォワードプロキシ -> NAT Gateway -> CodeCommit となります。そのため、本番環境で作成するpush用ユーザーのソースIPはNAT GatewayのIPアドレスで指定します。

## CodeCommit

本番環境にCodeCommitのリポジトリを作成します。また、CodeCommitにアクセスする専用のIAMユーザーも作成します。IAMユーザーはpush用とpull用の2つ作成します。push用のユーザーにはGitLabからリポジトリをミラーするのに必要な権限を与え、アクセス元のソースIPを開発環境のNAT Gatewayに限定します。これでCodeCommitへのpushは開発環境からのみ可能となり、本番環境および隔離環境からはpushできません。pull用のユーザーはpullに必要な権限を与え、アクセス元のソースIPを隔離環境の端末に限定します。

## 隔離環境端末

本番作業で使用する端末です。この環境の端末はプロキシ等でアクセスできる外部接続先が制限されています。開発用のGitLabには直接アクセスできません。

# Terraform

本リポジトリには以下のコード群を含みます。

- dev
  - VPC  (VPC、サブネット、インターネットゲートウェイ、NATゲートウェイを作成します。)
  - GitLab  (セルフホストのGitLabを作成します。)
- prd
  - CodeCommit  (リポジトリ、IAMユーザー(push用/pull用)を作成します。)

フォワードプロキシのコードは含まれていません。説明や注意事項は各モジュール配下のREDME.mdを確認してください。各モジュールの`versions.tf`は以下のように設定しています。自身の環境に合わせてタグ等は修正してください。

```
provider "aws" {
  region = "ap-northeast-1"
  default_tags {
    tags = {
      pj    = "mirror"
      env   = "dev"
      owner = "mori"
    }
  }
}
```

以下の順で構築します。3と4はフォワードプロキシを設定する場合のみ実施します。

## 1. terraform実行

以下のterraformを実行してください。自身の環境に合わせてterraform.tfvarsを修正してください。既存のリソースを使用する場合は実行しなくても良いです。devのコードは開発環境で、prdのコードは本番環境で実行してください。

- dev/vpc
- dev/gitlab
- prd/codecommit

## 2. CodeCommitユーザーの認証情報

CodeCommitモジュールで本番環境にIAMユーザーを作成した後、マネジメントコンソールでCodeCommitのHTTPS接続用のGit認証を作成します。やり方はAWSドキュメントの[Git 認証情報を使用した HTTPS ユーザーのセットアップ](https://docs.aws.amazon.com/ja_jp/codecommit/latest/userguide/setting-up-gc.html#setting-up-gc-iam)またはGitLabのドキュメントの[Set up a push mirror from GitLab to AWS CodeCommit](https://docs.gitlab.com/ee/user/project/repository/mirror/push.html#set-up-a-push-mirror-from-gitlab-to-aws-codecommit)にあります。作成した各ユーザーのUsernameとPasswordは控えておきます。

## 3. フォワードプロキシ作成

フォワードプロキシを使用しない場合は飛ばしてください。

開発環境のGitLabからインターネットへ出る前段にプロキシを建てます。AWSにフォワードプロキシを作成する方法は多々ありますが、私の環境にはEKSがあるためEKS Fargateでフォワードプロキシを構築します。やり方はこちらの[moriryota62/squid-on-eks](https://github.com/moriryota62/squid-on-eks)を参照ください。

## 4. GitLabにプロキシ設定

フォワードプロキシを使用しない場合は飛ばしてください。

開発環境のGitLabにフォワードプロキシを設定する方法はこちらの[Setting custom environment variables](https://docs.gitlab.com/omnibus/settings/environment-variables.html)が参考になります。ミラーの場合、gitalyにプロキシを設定します。
たとえば以下の様に/etc/gitlab/gitlab.rbを設定します。http_proxyおよびhttps_proxyの指定先はフォワードプロキシの公開アドレスです。

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

開発環境のGitLabのリポジトリでミラーを設定します。公式の設定方法は[Set up a push mirror from GitLab to AWS CodeCommit](https://docs.gitlab.com/ee/user/project/repository/mirror/push.html#set-up-a-push-mirror-from-gitlab-to-aws-codecommit)にあります。

1. GitLabのミラー対象リポジトリで`Settings`->`Repository`->`Mirroring repositories`を開く。

2. Git repository URLの入力ボックスにてCodeCommitのクローン用URL入力する。  
`https://mirror-prd-codecommit_access_user-at-456247553902@git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/mirror`  
のような形式で入力する。＠の前の部分は作成したCodeCommitモジュールで作成したpush用ユーザーのGit認証用のユーザー名を使っている。  

3. **Mirror direction**はPush、**Authentication method**はPasswordのままでOK

4. **Password**はpush用ユーザーのGit認証用のパスワードを使う。

5. `Mirror repository`で設定を反映する。

6. 追加するとMirrored repositoriesに追加される。右はしのリロードマークを押すとミラーリングを手動で実行できる。

7. 上記をリポジトリ毎に実施する。  

## 6. 隔離端末からCodeCommitをクローン

隔離環境の端末からCodeCommitのリポジトリをクローンします。マネジメントコンソール等でCodeCommitのHTTPSクローンURLを確認しクローンします。ユーザーとパスワードは本番環境で作成した隔離端末用ユーザーの認証情報を指定します。

## 7. 動作確認

1. 作業端末から開発環境のGitLabに修正を加えます。
2. 隔離端末から本番環境のCodeCommitをpullし、変更が反映されていることを確認します。
