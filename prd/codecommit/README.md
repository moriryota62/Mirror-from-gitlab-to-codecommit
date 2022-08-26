apply後にすること。

# IAMユーザーの認証情報

codecommitアクセスユーザーをterrafromで作成したらマネコンで`AWS CodeCommit の HTTPS Git 認証情報`から認証情報(ID/pass)を作成する。

# GitLabのミラー設定

1. 事前にGitLabにて“Admin” -> “Settings” -> “Network” -> “Outbound Requests” -> “Allow requests to the local network from hooks and services”の有効化を行う。  

2. OutputされたCodeCommitの各リポジトリのクローンURLを控えておく。

3. GitLabのミラー対象リポジトリ(terraform,k8s,docs)で`Settings`->`Repository`->`Mirroring repositories`を開く。

4. Git repository URLの入力ボックスにてCodeCommitのクローン用URL入力する。  
`https://cps-prd-codecommit_access_user-at-456247443832@git-codecommit.ap-northeast-1.amazonaws.com/v1/repos/terraform`  
のような形式で入力する。＠の前の部分は作成したIAMユーザーのGit認証用のユーザー名を使っている。  

5. **Mirror direction**はPush、**Authentication method**はPasswordのままでOK

6. **Password**はIAMユーザーのGit認証用のパスワードを使う。

7. `Mirror repository`で設定を反映する。

8. 追加するとMirrored repositoriesに追加される。右はしのリロードマークを押すとミラーリングを手動で実行できる。

9. 上記をリポジトリ毎(terraform,k8s,docs)に実施する。  