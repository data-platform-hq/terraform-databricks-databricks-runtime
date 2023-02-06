output "token" {
  value       = databricks_token.pat.token_value
  description = "Databricks Personal Authorization Token"
}

output "cluster_id" {
  value       = databricks_cluster.this.id
  description = "Databricks Cluster Id"
}

output "cluster_policies_object" {
  value = [for policy in var.custom_cluster_policies : {
    id      = databricks_cluster_policy.this[policy.name].id
    name    = databricks_cluster_policy.this[policy.name].name
    can_use = policy.can_use
  } if policy.definition != null]
  description = "Databricks Cluster Policies object map"
}
