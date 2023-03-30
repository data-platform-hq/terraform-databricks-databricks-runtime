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
  } if policy.definition != null && var.sku == "premium"]
  description = "Databricks Cluster Policies object map"
}
/*
output "secret_scope_object" {
  value = [for param in var.secret_scope : {
    scope_name = databricks_secret_scope.this[param.scope_name].name
    acl        = param.acl
  } if param.acl != null]
  description = "Databricks-managed Secret Scope object map to create ACLs"
}
*/