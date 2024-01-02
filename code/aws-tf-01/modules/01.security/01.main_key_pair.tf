# This is our main key for encryption
resource "aws_kms_key" "main_key_pair" {
  description             = "Our KMS key"
  deletion_window_in_days = 8
  enable_key_rotation     = true
  tags                    = merge(local.security_chapter_tags, { Name = "main_key_pair" })
}

resource "aws_kms_key_policy" "main_key_access_policy" {
  key_id = aws_kms_key.main_key_pair.id
  policy = data.aws_iam_policy_document.allow_kms_actions.json
}
