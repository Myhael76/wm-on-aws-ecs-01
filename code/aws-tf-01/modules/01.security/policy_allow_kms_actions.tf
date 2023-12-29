# Declare the required access to KMS actions by the logging services and the main account principal
data "aws_iam_policy_document" "allow_kms_actions" {
  statement {
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [data.aws_caller_identity.current.id]
    }

    actions = ["kms:*"]

    resources = [aws_kms_key.main_key_pair.arn]
  }
  statement {
    effect = "Allow"

    principals {
      type = "Service"
      identifiers = [formatlist("logs.%s.amazonaws.com", var.deployment_regions_list)]
    }

    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    resources = [aws_kms_key.main_key_pair.arn]
  }

}
