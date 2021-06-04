resource "aws_backup_vault" "jenkins_vault" {
  provider    = aws.use1
  name        = "jenkins_vault"
  kms_key_arn = "arn:aws:kms:us-east-1:143269240300:key/cb211a28-db0b-4355-83f6-b824067811d5"
}

resource "aws_backup_vault" "jenkins_vault_usw2" {
  provider    = aws.usw2
  name        = "jenkins_vault"
  kms_key_arn = "arn:aws:kms:us-west-2:143269240300:key/d430124e-a132-4d74-9763-46cc9c3f64a8"
}

resource "aws_backup_plan" "jenkins_backup_plan" {
  provider = aws.use1
  name     = "jenkins_backup_plan"
  rule {
    rule_name         = "jenkins_backup_plan_rule"
    target_vault_name = aws_backup_vault.jenkins_vault.name
    # CRON schedule: https://docs.aws.amazon.com/AmazonCloudWatch/latest/events/ScheduledEvents.html#CronExpressions
    # This is set to 6AM due to it being in UTC time.
    schedule          = "cron(0 6 ? * 1 *)"
    lifecycle {
      delete_after    = 21
    }
    copy_action {
      lifecycle {
        delete_after  = 21
      }
      destination_vault_arn = aws_backup_vault.jenkins_vault_usw2.arn
    }
  }
  tags = merge(
    local.common_tags
  )
}

data "aws_iam_role" "efs-backup-role" {
  name = "efs-backup-role"
}

resource "aws_backup_selection" "jenkins_backup_selection" {
  provider     = aws.use1
  iam_role_arn = data.aws_iam_role.efs-backup-role.arn
  name         = "jenkins_backup_selection"
  plan_id      = aws_backup_plan.jenkins_backup_plan.id
  resources    = [
    aws_efs_file_system.jenkins_backend.arn
  ]
}