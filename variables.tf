variable "workspace_id" {
  type        = string
  description = "Databricks Workspace ID"
}

variable "sp_client_id_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains ClientID of Service Principal to access in Azure Key Vault"
}

variable "sp_key_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains client secret of Service Principal to access in Azure Key Vault"
}

variable "tenant_id_secret_name" {
  type        = string
  description = "The name of Azure Key Vault secret that contains tenant ID secret of Service Principal to access in Azure Key Vault"
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault instance where the Secret resides"
}

# Optional
variable "sku" {
  type        = string
  description = "The sku to use for the Databricks Workspace: [standard|premium|trial]"
  default     = "standard"
}

variable "pat_token_lifetime_seconds" {
  type        = number
  description = "The lifetime of the token, in seconds. If no lifetime is specified, the token remains valid indefinitely"
  default     = 315569520
}

variable "cluster_nodes_availability" {
  type        = string
  description = "Availability type used for all subsequent nodes past the first_on_demand ones: [SPOT_AZURE|SPOT_WITH_FALLBACK_AZURE|ON_DEMAND_AZURE]"
  default     = null
}

variable "first_on_demand" {
  type        = number
  description = "The first first_on_demand nodes of the cluster will be placed on on-demand instances: [[:number]]"
  default     = 0
}

variable "spot_bid_max_price" {
  type        = number
  description = "The max price for Azure spot instances. Use -1 to specify lowest price."
  default     = -1
}

variable "autotermination_minutes" {
  type        = number
  description = "Automatically terminate the cluster after being inactive for this time in minutes. If not set, Databricks won't automatically terminate an inactive cluster. If specified, the threshold must be between 10 and 10000 minutes. You can also set this value to 0 to explicitly disable automatic termination."
  default     = 15
}

variable "min_workers" {
  type        = number
  description = "The minimum number of workers to which the cluster can scale down when underutilized. It is also the initial number of workers the cluster will have after creation."
  default     = 1
}

variable "max_workers" {
  type        = number
  description = "The maximum number of workers to which the cluster can scale up when overloaded. max_workers must be strictly greater than min_workers."
  default     = 2
}

variable "users" {
  type        = list(string)
  description = "List of users to access Databricks"
  default     = []
}

variable "secrets" {
  type        = map(any)
  description = "Map of secrets to create in Databricks"
  default     = {}
}

variable "use_local_secret_scope" {
  type        = bool
  description = "Create databricks secret scope and create secrets"
  default     = false
}

variable "permissions" {
  type        = list(map(string))
  description = "Databricks Workspace permission maps"
  default = [
    {
      object_id = null
      role      = null
    }
  ]
}

variable "data_security_mode" {
  type        = string
  description = "Security features of the cluster"
  default     = "NONE"
  validation {
    condition     = contains(["SINGLE_USER", "USER_ISOLATION", "NONE"], var.data_security_mode)
    error_message = "Catalog Access mode must be either 'SINGLE_USER', 'USER_ISOLATION' or 'NONE' value"
  }
}

variable "spark_version" {
  type        = string
  description = "Runtime version"
  default     = "11.3.x-scala2.12"
}

variable "spark_conf" {
  type        = map(any)
  description = "Map with key-value pairs to fine-tune Spark clusters, where you can provide custom Spark configuration properties in a cluster configuration."
  default     = {}
}

variable "cluster_log_conf_destination" {
  type        = string
  description = "Provide a dbfs location, example 'dbfs:/cluster-logs', to push all cluster logs to certain location"
  default     = ""
  validation {
    condition     = length(var.cluster_log_conf_destination) == 0 ? true : startswith(var.cluster_log_conf_destination, "dbfs:/")
    error_message = "Provide valid path to dbfs logs folder, example: 'dbfs:/mnt/logs'"
  }
}

variable "node_type" {
  type        = string
  description = "Databricks_node_type id"
  default     = "Standard_D3_v2"
}

variable "mountpoints" {
  type        = map(any)
  description = "Mountpoints for databricks"
  default     = null
}
