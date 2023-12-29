# Need to create a role to allow for logging
resource "aws_iam_role" "logger_artifact_role" {
  name                = var.logger_artifact_role_name
  assume_role_policy  = data.aws_iam_policy_document.assume_role_for_logging.json
  # we use the managed policy to log
  # managed_policy_arns = [data.aws_iam_policy.full_log_policy.arn]
  tags                = merge(local.security_chapter_tags, { Name = "logger_artifact_role" })
}
