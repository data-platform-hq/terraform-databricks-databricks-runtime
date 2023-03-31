locals {
  sp_secrets = {
    (var.sp_client_id_secret_name) = { value = data.azurerm_key_vault_secret.sp_client_id.value }
    (var.sp_key_secret_name)       = { value = data.azurerm_key_vault_secret.sp_key.value }
  }
}

# Secret Scope with SP secrets for mounting Azure Data Lake Storage
resource "databricks_secret_scope" "main" {
  name                     = "main"
  initial_manage_principal = "users"
}

resource "databricks_secret" "main" {
  for_each = local.sp_secrets

  key          = each.key
  string_value = each.value["value"]
  scope        = databricks_secret_scope.main.id
}
