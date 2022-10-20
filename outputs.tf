output "token" {
  value       = databricks_token.pat.token_value
  description = "Databricks Personal Authorization Token"
}

output "cluster_id" {
  value       = databricks_cluster.this.id
  description = "Databricks Cluster Id"
}
