data "azurerm_key_vault_secret" "sp_client_id" {
  name         = var.sp_client_id_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "sp_key" {
  name         = var.sp_key_secret_name
  key_vault_id = var.key_vault_id
}

data "azurerm_key_vault_secret" "tenant_id" {
  name         = var.tenant_id_secret_name
  key_vault_id = var.key_vault_id
}

locals {
  secrets = merge(var.secrets, {
    (var.sp_client_id_secret_name) = { value = data.azurerm_key_vault_secret.sp_client_id.value }
    (var.sp_key_secret_name)       = { value = data.azurerm_key_vault_secret.sp_key.value }
  })
}

resource "databricks_token" "pat" {
  comment          = "Terraform Provisioning"
  lifetime_seconds = var.pat_token_lifetime_seconds
}

resource "databricks_user" "this" {
  for_each  = var.sku == "standard" ? toset(var.users) : []
  user_name = each.value
  lifecycle { ignore_changes = [external_id] }
}

resource "azurerm_role_assignment" "this" {
  for_each = {
    for permision in var.permissions : "${permision.object_id}-${permision.role}" => permision
    if permision.role != null
  }
  scope                = var.workspace_id
  role_definition_name = each.value.role
  principal_id         = each.value.object_id
}

resource "databricks_cluster" "this" {
  cluster_name  = "shared autoscaling"
  spark_version = var.spark_version

  node_type_id            = var.node_type
  autotermination_minutes = var.autotermination_minutes

  autoscale {
    min_workers = var.min_workers
    max_workers = var.max_workers
  }

  azure_attributes {
    availability       = var.cluster_nodes_availability
    first_on_demand    = var.first_on_demand
    spot_bid_max_price = var.spot_bid_max_price
  }

  lifecycle {
    ignore_changes = [
      state
    ]
  }
}
