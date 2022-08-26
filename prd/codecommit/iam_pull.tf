resource "aws_iam_user" "codecommit_pull_user" {
  name = "${var.base_name}-codecommit_pull_user"

  tags = {
    "Name" = "${var.base_name}-codecommit_pull_user"
  }
}

resource "aws_iam_policy" "codecommit_pull_user" {
  name = "${var.base_name}-CodecommitPullUserPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Effect" : "Allow",
      "Action" : [
        "codecommit:Describe*",
        "codecommit:Get*",
        "codecommit:List*",
        "codecommit:GitPull"
      ],
      "Resource" : "*"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "codecommit_pull_user_access" {
  name = "${var.base_name}-CodecommitPullUserAccessPolicy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement" : [
    {
      "Sid": "AllowRestriction",
      "Action": [ "*" ],
      "Effect": "Deny",
      "Resource": [ "*" ],
      "Condition": {
         "NotIpAddress": {
             "aws:SourceIp": ["${var.secureroom_ipadress}/32"]
          },
         "Bool": {
             "aws:ViaAWSService": "false"
          }
      }
    }
  ]
}
EOF

}

resource "aws_iam_user_policy_attachment" "codecommit_pull_user" {
  user       = aws_iam_user.codecommit_pull_user.name
  policy_arn = aws_iam_policy.codecommit_pull_user.arn
}

resource "aws_iam_user_policy_attachment" "codecommit_pull_user_access" {
  user       = aws_iam_user.codecommit_pull_user.name
  policy_arn = aws_iam_policy.codecommit_pull_user_access.arn
}