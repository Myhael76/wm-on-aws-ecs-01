output "log_iam_role_arn" {
  description = "ARN of the assume role construct for logging"
  value       = aws_iam_role.log_iam_role.arn
}

output "log_destination_arn" {
  description = "ARN of the log destination"
  value       = aws_cloudwatch_log_group.cloudwatch_destination_log_group.arn
}


output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.cloudwatch_destination_log_group.name
}

output "kms_key_arn" {
  description = "Log encryption key arn"
  value       = aws_kms_key.log_enc_key.arn
}
