# Databricks Workspace Terraform module
Terraform module used for Databricks Workspace configuration and Resources creation

## Usage
This module provides an ability for Databricks Workspace configuration and Resources creation, for example:
1. Default Shared Autoscaling cluster
2. ADLS Gen2 Mount
3. Secret scope and its secrets
4. Cluster policies
5. Users for Standard SKU Worspaces

```hcl
# Prerequisite resources
data "azurerm_databricks_workspace" "example" {
  name                = "example-workspace"
  resource_group_name = "example-rg"
}

# Databricks Provider configuration
provider "databricks" {
  alias                       = "main"
  host                        = data.azurerm_databricks_workspace.example.workspace_url
  azure_workspace_resource_id = data.azurerm_databricks_workspace.example.id
}

# Key Vault which contains Service Principal credentials (App ID and Secret) for mounting ADLS Gen 2
data "azurerm_key_vault" "example" {
  name                = "example-key-vault"
  resource_group_name = "example-rg"
}

data "azurerm_storage_account" "example" {
  name                = "examplestorage"
  resource_group_name = "example-rg"
}

# Databricks Runtime module usage example
module "databricks_runtime_core" {
  source  = "data-platform-hq/databricks-runtime/databricks"

  sku          = "premium"
  workspace_id = data.azurerm_databricks_workspace.example.workspace_id
  
  # This parameter only used when workspace wku equals 'standard'
  users        = ["user1", "user2"]  

  # Parameters of Service principal used for ADLS mount
  # Imports App ID and Secret of Service Principal from target Key Vault
  key_vault_id             =  data.azurerm_key_vault.example.id
  sp_client_id_secret_name = "sp-client-id" # secret's name that stores Service Principal App ID
  sp_key_secret_name       = "sp-key" # secret's name that stores Service Principal Secret Key
  tenant_id_secret_name    = "infra-arm-tenant-id" # secret's name that stores tenant id value

  # Default cluster parameters
  custom_default_cluster_name  = "databricks_example_custer"
  cluster_nodes_availability   = "SPOT_AZURE" # it required to increase Regional Spot quotas  
  cluster_log_conf_destination = "dbfs:/cluster-logs"
  custom_cluster_policies      =  [{
    name     = "custom_policy_1",
    assigned = true,
    can_use  =  null,
    definition = {
      "autoscale.max_workers": {
        "type": "range",
        "maxValue": 3,
        "defaultValue": 2
      },
    }
  }]

  # Additional Secret Scope
  secret_scope = [{
    scope_name = "extra-scope"
    acl        = null # Only group names are allowed. If left empty then only Workspace admins could access these keys
    secrets    = [
      { key = "secret-name", string_value = "secret-value"}
    ]
  }]

  mountpoints = {
    storage_account_name = data.azurerm_storage_account.example.name
    container_name       = "example_container"
  }

  providers = {
    databricks = databricks.main
  }
}
```
<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                         | Version   |
| ---------------------------------------------------------------------------- | --------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform)    | >= 1.0.0  |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm)          | >= 3.40.0 |
| <a name="requirement_databricks"></a> [databricks](#requirement\_databricks) | >= 1.9.2  |

## Providers

| Name                                                                   | Version |
| ---------------------------------------------------------------------- | ------- |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm)          | 3.40.0  |
| <a name="provider_databricks"></a> [databricks](#provider\_databricks) | 1.9.2   |

## Modules

No modules.

## Resources

| Name                                                                                                                                      | Type     |
| ----------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| [azurerm_key_vault_secret.sp_client_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | data     |
| [azurerm_key_vault_secret.sp_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)       | data     |
| [azurerm_key_vault_secret.tenant_id](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret)    | data     |
| [databricks_token.pat](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/token)                         | resource |
| [databricks_user.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/user)                          | resource |
| [azurerm_role_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment)           | resource |
| [databricks_cluster.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/cluster)           | resource |
| [databricks_mount.adls](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/mount)                        | resource |
| [databricks_secret_scope.main](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope)          | resource |
| [databricks_secret.main](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret)                      | resource |
| [databricks_secret_scope.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret_scope)          | resource |
| [databricks_secret.this](https://registry.terraform.io/providers/databricks/databricks/latest/docs/resources/secret)                      | resource |

## Inputs

| Name                                                                                                                         | Description                                                                                                                                                                                                                                                                                                 | Type                                                                                                                                                                                                                                                  | Default                                                                                                                   | Required |
| ---------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------- | :------: |
| <a name="input_workspace_id"></a> [workspace\_id](#input\_workspace\_id)                                                     | Databricks Workspace ID                                                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                              | n/a                                                                                                                       |   yes    |
| <a name="input_sp_client_id_secret_name"></a> [sp\_client\_id\_secret\_name](#input\_sp\_client\_id\_secret\_name)           | The name of Azure Key Vault secret that contains ClientID of Service Principal to access in Azure Key Vault                                                                                                                                                                                                 | `string`                                                                                                                                                                                                                                              | n/a                                                                                                                       |   yes    |
| <a name="input_sp_key_secret_name"></a> [sp\_key\_secret\_name](#input\_sp\_key\_secret\_name)                               | The name of Azure Key Vault secret that contains client secret of Service Principal to access in Azure Key Vault                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                              | n/a                                                                                                                       |   yes    |
| <a name="input_tenant_id_secret_name"></a> [tenant\_id\_secret\_name](#input\_tenant\_id\_secret\_name)                      | The name of Azure Key Vault secret that contains tenant ID secret of Service Principal to access in Azure Key Vault                                                                                                                                                                                         | `string`                                                                                                                                                                                                                                              | n/a                                                                                                                       |   yes    |
| <a name="input_key_vault_id"></a> [key\_vault\_id](#input\_key\_vault\_id)                                                   | ID of the Key Vault instance where the Secret resides                                                                                                                                                                                                                                                       | `string`                                                                                                                                                                                                                                              | n/a                                                                                                                       |   yes    |
| <a name="input_pat_token_lifetime_seconds"></a> [pat\_token\_lifetime\_seconds](#input\_pat\_token\_lifetime\_seconds)       | The lifetime of the token, in seconds. If no lifetime is specified, the token remains valid indefinitely                                                                                                                                                                                                    | `number`                                                                                                                                                                                                                                              | 315569520                                                                                                                 |    no    |
| <a name="input_users"></a> [users](#input\_users)                                                                            | List of users to access Databricks                                                                                                                                                                                                                                                                          | `list(string)`                                                                                                                                                                                                                                        | []                                                                                                                        |    no    |
| <a name="input_permissions"></a> [permissions](#input\_permissions)                                                          | Databricks Workspace permission maps                                                                                                                                                                                                                                                                        | `list(map(string))`                                                                                                                                                                                                                                   | <pre> [{   <br>   object_id = null   <br>   role      = null <br> }] </pre>                                               |    no    |
| <a name="input_cluster_nodes_availability"></a> [cluster\_nodes\_availability](#input\_cluster\_nodes\_availability)         | Availability type used for all subsequent nodes past the first_on_demand ones: [SPOT_AZURE \  SPOT_WITH_FALLBACK_AZURE \  ON_DEMAND_AZURE]                                                                                                                                                                  | `string`                                                                                                                                                                                                                                              | null                                                                                                                      |    no    |
| <a name="input_first_on_demand"></a> [first\_on\_demand](#input\_first\_on\_demand)                                          | The first first_on_demand nodes of the cluster will be placed on on-demand instances: [[ \:number ]]                                                                                                                                                                                                        | `number`                                                                                                                                                                                                                                              | 0                                                                                                                         |    no    |
| <a name="input_spot_bid_max_price"></a> [spot\_bid\_max\_price](#input\_spot\_bid\_max\_price)                               | The max price for Azure spot instances. Use -1 to specify lowest price                                                                                                                                                                                                                                      | `number`                                                                                                                                                                                                                                              | -1                                                                                                                        |    no    |
| <a name="input_autotermination_minutes"></a> [autotermination\_minutes](#input\_autotermination\_minutes)                    | Automatically terminate the cluster after being inactive for this time in minutes. If not set, Databricks won't automatically terminate an inactive cluster. If specified, the threshold must be between 10 and 10000 minutes. You can also set this value to 0 to explicitly disable automatic termination | `number`                                                                                                                                                                                                                                              | 15                                                                                                                        |    no    |
| <a name="input_min_workers"></a> [min\_workers](#input\_min\_workers)                                                        | The minimum number of workers to which the cluster can scale down when underutilized. It is also the initial number of workers the cluster will have after creation                                                                                                                                         | `number`                                                                                                                                                                                                                                              | 1                                                                                                                         |    no    |
| <a name="input_max_workers"></a> [max\_workers](#input\_max\_workers)                                                        | The maximum number of workers to which the cluster can scale up when overloaded. max_workers must be strictly greater than min_workers                                                                                                                                                                      | `number`                                                                                                                                                                                                                                              | 2                                                                                                                         |    no    |
| <a name="input_data_security_mode"></a> [data\_security\_mode](#input\_data\_security\_mode)                                 | Security features of the cluster                                                                                                                                                                                                                                                                            | `string`                                                                                                                                                                                                                                              | "NONE"                                                                                                                    |    no    |
| <a name="input_custom_default_cluster_name"></a> [custom\_default\_cluster\_name](#input\_custom\_default\_cluster\_name)    | Databricks cluster name, which does not have to be unique                                                                                                                                                                                                                                                   | `string`                                                                                                                                                                                                                                              | `null`                                                                                                                    |    no    |
| <a name="input_spark_version"></a> [spark\_version](#input\_spark\_version)                                                  | Runtime version                                                                                                                                                                                                                                                                                             | `string`                                                                                                                                                                                                                                              | "11.3.x-scala2.12"                                                                                                        |    no    |
| <a name="input_spark_conf"></a> [spark\_conf](#input\_spark\_conf)                                                           | Map with key-value pairs to fine-tune Spark clusters, where you can provide custom Spark configuration properties in a cluster configuration.                                                                                                                                                               | `map(any)`                                                                                                                                                                                                                                            | {}                                                                                                                        |    no    |
| <a name="input_spark_env_vars"></a> [spark_env_vars](#input\_spark_env_vars)                                                 | Map with environment variable key-value pairs to fine-tune Spark clusters. Key-value pairs of the form (X,Y) are exported (i.e., X='Y') while launching the driver and workers.                                                                                                                             | `map(any)`                                                                                                                                                                                                                                            | {}                                                                                                                        |    no    |
| <a name="input_cluster_log_conf_destination"></a> [cluster\_log\_conf\_destination](#input\_cluster\_log\_conf\_destination) | Provide a dbfs location, example 'dbfs:/cluster-logs', to push all cluster logs to certain location                                                                                                                                                                                                         | `string`                                                                                                                                                                                                                                              | " "                                                                                                                       |    no    |
| <a name="input_node_type"></a> [node\_type](#input\_node\_type)                                                              | Databricks_node_type id                                                                                                                                                                                                                                                                                     | `string`                                                                                                                                                                                                                                              | "Standard_D3_v2"                                                                                                          |    no    |
| <a name="input_mountpoints"></a> [mountpoints](#input\_mountpoints)                                                          | Mountpoints for databricks                                                                                                                                                                                                                                                                                  | `map(any)`                                                                                                                                                                                                                                            | null                                                                                                                      |    no    |
| <a name="input_secret_scope"></a> [secret\_scope](#input\_secret\_scope)                                                     | Provides an ability to create custom Secret Scope, store secrets in it and assigning ACL for access management                                                                                                                                                                                              | <pre>list(object({<br>  scope_name = string<br>  acl = optional(list(object({<br>    principal  = string<br>    permission = string<br>  secrets = optional(list(object({<br>    key          = string<br>    string_value = string<br>})))<br></pre> | <pre>default = [{<br>  scope_name = null<br>  acl        = null<br>  can_use    = null<br>  secrets    = null<br>}]</pre> |    no    |



## Outputs

| Name                                                                                                          | Description                                               |
| ------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------- |
| <a name="output_token"></a> [token](#output\_token)                                                           | Databricks Personal Authorization Token                   |
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id)                                          | Databricks Cluster Id                                     |
<!-- END_TF_DOCS -->

## License

Apache 2 Licensed. For more information please see [LICENSE](https://github.com/data-platform-hq/terraform-databricks-databricks-runtime/blob/main/LICENSE)
