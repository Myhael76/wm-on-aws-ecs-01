output "our_log_iam_role_arn" {
  description = "ARN of the assume role construct for logging"
  value       = aws_iam_role.our_log_iam_role.arn
}

output "our_log_destination_arn" {
  description = "ARN of the log destination"
  value       = aws_cloudwatch_log_group.cloudwatch_destination_log_group.arn
}
