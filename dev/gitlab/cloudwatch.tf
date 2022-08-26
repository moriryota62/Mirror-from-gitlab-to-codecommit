# CloudWatchイベント - EC2の定時起動
resource "aws_cloudwatch_event_rule" "start_gitlab_rule" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  name                = "${var.base_name}-Gitlab-StartRule"
  description         = "Start ${var.base_name} Gitlab"
  schedule_expression = var.cloudwatch_start_schedule

  tags = {
    "Name" = "${var.base_name}-Gitlab-StartRule"
  }
}

resource "aws_cloudwatch_event_target" "start_gitlab" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  target_id = "StartInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StartEC2Instance"
  rule      = aws_cloudwatch_event_rule.start_gitlab_rule.0.name
  role_arn  = aws_iam_role.gitlab_ssm_automation.0.arn

  input = <<DOC
{
  "InstanceId": ["${aws_instance.gitlab.id}"]
}
DOC
}

# CloudWatchイベント - EC2の定時停止
resource "aws_cloudwatch_event_rule" "stop_gitlab_rule" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  name                = "${var.base_name}-Gitlab-StopRule"
  description         = "Stop ${var.base_name} Gitlab"
  schedule_expression = var.cloudwatch_stop_schedule

  tags = {
    "Name" = "${var.base_name}-Gitlab-StopRule"
  }
}

resource "aws_cloudwatch_event_target" "stop_gitlab" {
  count = var.cloudwatch_enable_schedule ? 1 : 0

  target_id = "StopInstanceTarget"
  arn       = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:automation-definition/AWS-StopEC2Instance"
  rule      = aws_cloudwatch_event_rule.stop_gitlab_rule.0.name
  role_arn  = aws_iam_role.gitlab_ssm_automation.0.arn

  input = <<DOC
{
  "InstanceId": ["${aws_instance.gitlab.id}"]
}
DOC
}
