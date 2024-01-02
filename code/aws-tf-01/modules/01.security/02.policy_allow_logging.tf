##### Required policies to enable logging

# Allow creation of logging artifacts and entries
data "aws_iam_policy_document" "allow_logging_policy_document" {
  # checkov:skip=CKV_AWS_111: TODO: check how to resolve in the future
  statement {
    effect = "Allow"
    actions = [
      # "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      #"logs:DescribeLogGroups",
      #"logs:DescribeLogStreams",
    ]

    #trivy:ignore:AVD-AWS-0057: TODO: check how to resolve in the future
    resources = ["*"]
  }
}

# Attach the allow logging policy to the role "logger_artifact"
resource "aws_iam_role_policy" "allow_logging_for_logger_artifact" {
  name   = "allow_logging"
  role   = aws_iam_role.logger_artifact_role.id
  policy = data.aws_iam_policy_document.allow_logging_policy_document.json
}

# Allow the service vpc-flow-logs to execute the action "assume role"
data "aws_iam_policy_document" "assume_role_for_logging" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}
