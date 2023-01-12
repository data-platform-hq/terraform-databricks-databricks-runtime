resource "databricks_secret_scope" "this" {
  count = var.use_local_secret_scope ? 1 : 0

  name                     = "main"
  initial_manage_principal = "users"
}

resource "databricks_secret" "this" {
  for_each = var.use_local_secret_scope ? local.secrets : {}

  key          = each.key
  string_value = each.value["value"]
  scope        = databricks_secret_scope.this[0].id

  depends_on = [databricks_secret_scope.this]
}
