resource "aws_cloudwatch_log_group" "jenkins_log_group" {
  name              = "/ecs/jenkins"
  retention_in_days = 14
  tags              = merge(
    local.common_tags
  )
}

resource "aws_cloudwatch_log_group" "kinesis_error_group" {
  name              = "kinesis_error_group"
  retention_in_days = 14
  tags              = merge(
    local.common_tags
  )
}

data "aws_iam_role" "firehose_role" {
    name = "firehose-write-logging-s3"
}

resource "aws_kinesis_firehose_delivery_stream" "firehose_s3_logging_account" {
  name        = "firehose_s3_logging_account"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn           = data.aws_iam_role.firehose_role.arn
    bucket_arn         = "arn:aws:s3:::alsac-log-jenkins-logs"
    prefix             = "${var.account_numbers[var.env]}/"
    compression_format = "UNCOMPRESSED"
    cloudwatch_logging_options {
      enabled = true
      log_group_name = aws_cloudwatch_log_group.kinesis_error_group.name
      log_stream_name = "errors"
    }
  }
  server_side_encryption {
    enabled = true
  }
  
  tags = merge(
    local.common_tags
  )
}

data "aws_iam_role" "cloudwatch_role" {
    name = "cloudwatch-logs-write-firehose"
}

resource "aws_cloudwatch_log_subscription_filter" "kinesis_logfilter" {
  name            = "kinesis_logfilter"
  role_arn        = data.aws_iam_role.cloudwatch_role.arn
  log_group_name  = aws_cloudwatch_log_group.jenkins_log_group.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.firehose_s3_logging_account.arn
  distribution    = "ByLogStream"
}