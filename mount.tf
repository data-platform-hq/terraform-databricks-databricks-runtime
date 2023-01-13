locals {
  secret_scope_name = var.use_local_secret_scope ? databricks_secret_scope.this[0].name : "main"
  mount_secret_name = var.use_local_secret_scope ? databricks_secret.this[var.sp_key_secret_name].config_reference : "{{secrets/${local.secret_scope_name}/${data.azurerm_key_vault_secret.sp_key.name}}}"
}

resource "databricks_mount" "adls" {
  for_each = var.mountpoints

  name = each.key
  uri  = "abfss://${each.value["container_name"]}@${each.value["storage_account_name"]}.dfs.core.windows.net/${each.value["root_path"]}"
  extra_configs = {
    "fs.azure.account.auth.type" : "OAuth",
    "fs.azure.account.oauth.provider.type" : "org.apache.hadoop.fs.azurebfs.oauth2.ClientCredsTokenProvider",
    "fs.azure.account.oauth2.client.id" : data.azurerm_key_vault_secret.sp_client_id.value,
    "fs.azure.account.oauth2.client.secret" : local.mount_secret_name,
    "fs.azure.account.oauth2.client.endpoint" : "https://login.microsoftonline.com/${data.azurerm_key_vault_secret.tenant_id.value}/oauth2/token",
    "fs.azure.createRemoteFileSystemDuringInitialization" : "false",
    "spark.databricks.sqldw.jdbc.service.principal.client.id" : data.azurerm_key_vault_secret.sp_client_id.value,
    "spark.databricks.sqldw.jdbc.service.principal.client.secret" : local.mount_secret_name,
  }
}
