output "meta_tags" {
  description = "Main project meta tags"
  value       = local.meta_tags
}

output "project_rg_name" {
  description = "Project resource group name"
  value       = aws_resourcegroups_group.resource_group.name
}
