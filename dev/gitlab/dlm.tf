resource "aws_dlm_lifecycle_policy" "this" {
  description        = "GitLab Daily snapshot lifecycle policy"
  execution_role_arn = aws_iam_role.dlm_lifecycle_role.arn
  state              = "ENABLED"

  policy_details {
    resource_types = ["INSTANCE"]
    policy_type    = "IMAGE_MANAGEMENT"

    schedule {
      name = "daily snapshots"

      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["17:00"]
      }

      retain_rule {
        count = 7
      }

      tags_to_add = {
        SnapshotCreator = "DLM"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "${var.base_name}-gitlab"
    }
  }

  tags = {
    Name = "${var.base_name}-gitlab-daily-snapshot"
  }
}