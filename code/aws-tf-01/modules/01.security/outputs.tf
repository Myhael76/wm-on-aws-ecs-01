output "logger_artifact_role_arn" {
  description = "Logger artifact role ARN"
  value       = aws_iam_role.logger_artifact_role.arn
}

output "main_key_pair_arn" {
  description = "Main key pair ARN"
  value       = aws_kms_key.main_key_pair.arn
}
