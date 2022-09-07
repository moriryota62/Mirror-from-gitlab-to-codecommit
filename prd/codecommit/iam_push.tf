resource "aws_iam_user" "codecommit_push_user" {
  name = "${var.base_name}-codecommit_push_user"

  tags = {
    "Name" = "${var.base_name}-codecommit_push_user"
  }
}

resource "aws_iam_policy" "codecommit_push_user" {
  name = "${var.base_name}-CodecommitPushUserPolicy"

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
        "codecommit:GitPull",
        "codecommit:GitPush"
      ],
      "Resource" : "*"
    }
  ]
}
EOF

}

resource "aws_iam_policy" "codecommit_push_user_access" {
  name = "${var.base_name}-CodecommitPushUserAccessPolicy"

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
             "aws:SourceIp": ${var.incomming_ipadress}
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

resource "aws_iam_user_policy_attachment" "codecommit_push_user" {
  user       = aws_iam_user.codecommit_push_user.name
  policy_arn = aws_iam_policy.codecommit_push_user.arn
}

resource "aws_iam_user_policy_attachment" "codecommit_push_user_access" {
  user       = aws_iam_user.codecommit_push_user.name
  policy_arn = aws_iam_policy.codecommit_push_user_access.arn
}