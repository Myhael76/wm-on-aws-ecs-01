output "log_destination_arn" {
  description = "ARN of the log destination"
  value       = aws_cloudwatch_log_group.cloudwatch_destination_log_group.arn
}


output "log_group_name" {
  description = "CloudWatch log group name"
  value       = aws_cloudwatch_log_group.cloudwatch_destination_log_group.name
}
