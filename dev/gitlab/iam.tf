data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.base_name}-GitlabRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

  tags = {
    "Name" = "${var.base_name}-GitlabRole"
  }
}

data "aws_iam_policy" "systems_manager" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  role       = aws_iam_role.role.name
  policy_arn = data.aws_iam_policy.systems_manager.arn
}

resource "aws_iam_instance_profile" "gitlab" {
  name = "${var.base_name}-gitlab-instance-profile"
  role = aws_iam_role.role.name
}

# 自動スケジュール設定
## CloudWatch Eventsで使用するIAMロール
resource "aws_iam_role" "gitlab_ssm_automation" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  name               = "${var.base_name}-Gitlab-SSMautomationRole"
  assume_role_policy = data.aws_iam_policy_document.gitlab_ssm_automation_trust.json

  tags = {
    "Name" = "${var.base_name}-Gitlab-SSMautomationRole"
  }
}

## CloudWatch EventsのIAMロールにSSM Automationのポリシーを付与
resource "aws_iam_role_policy_attachment" "ssm-automation-atach-policy" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  role       = aws_iam_role.gitlab_ssm_automation.0.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

## CloudWatch EventsからのaasumeRoleを許可するポリシー
data "aws_iam_policy_document" "gitlab_ssm_automation_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

# 自動スナップショット
resource "aws_iam_role" "dlm_lifecycle_role" {
  name = "${var.base_name}-gitlab-dlm-lifecycle-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "dlm.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "dlm_lifecycle" {
  name = "${var.base_name}-gitlab-dlm-lifecycle--policy"
  role = aws_iam_role.dlm_lifecycle_role.id

  policy = <<EOF
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": "ec2:CreateTags",
			"Resource": [
				"arn:aws:ec2:*::snapshot/*",
				"arn:aws:ec2:*::image/*"
			]
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:DescribeImages",
				"ec2:DescribeInstances",
				"ec2:DescribeImageAttribute",
				"ec2:DescribeInstances",
				"ec2:DescribeVolumes",
				"ec2:DescribeSnapshots"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": "ec2:DeleteSnapshot",
			"Resource": "arn:aws:ec2:*::snapshot/*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:ResetImageAttribute",
				"ec2:DeregisterImage",
				"ec2:CreateImage",
				"ec2:CopyImage",
				"ec2:ModifyImageAttribute"
			],
			"Resource": "*"
		},
		{
			"Effect": "Allow",
			"Action": [
				"ec2:EnableImageDeprecation",
				"ec2:DisableImageDeprecation"
			],
			"Resource": "arn:aws:ec2:*::image/*"
		}
	]
}
EOF
}