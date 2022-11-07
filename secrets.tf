locals {
  secret_scope_name = var.use_local_secret_scope ? databricks_secret_scope.this[0].name : "main"
  mount_secret_name = var.use_local_secret_scope ? databricks_secret.this[var.sp_key_secret_name].key : data.azurerm_key_vault_secret.sp_key.name
}
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
