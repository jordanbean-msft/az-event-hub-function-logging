locals {
  tags           = { azd-env-name : var.environment_name }
  sha            = base64encode(sha256("${var.location}${var.resource_group_name}${data.azurerm_client_config.current.subscription_id}"))
  resource_token = substr(replace(lower(local.sha), "[^A-Za-z0-9_]", ""), 0, 13)
}

# ------------------------------------------------------------------------------------------------------
# Deploy application insights
# ------------------------------------------------------------------------------------------------------
module "application_insights" {
  source              = "./modules/application_insights"
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = module.log_analytics.log_analytics_workspace_id
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy log analytics
# ------------------------------------------------------------------------------------------------------
module "log_analytics" {
  source              = "./modules/log_analytics"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy managed identity
# ------------------------------------------------------------------------------------------------------
module "managed_identity" {
  source              = "./modules/managed_identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
  resource_token      = local.resource_token
}

# ------------------------------------------------------------------------------------------------------
# Deploy Storage Account
# ------------------------------------------------------------------------------------------------------

module "storage_account" {
  source                        = "./modules/storage_account"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  resource_token                = local.resource_token
  account_tier                  = var.storage_account.tier
  account_replication_type      = var.storage_account.replication_type
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Event Hub
# ------------------------------------------------------------------------------------------------------

module "event_hub" {
  source                        = "./modules/event_hub"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tags                          = local.tags
  resource_token                = local.resource_token
  managed_identity_principal_id = module.managed_identity.user_assigned_identity_principal_id
  event_hub_namespace_sku       = var.event_hub.namespace_sku
  capacity                      = var.event_hub.capacity
  maximum_throughput_units      = var.event_hub.maximum_throughput_units
  partition_count               = var.event_hub.partition_count
  message_retention             = var.event_hub.message_retention
  log_analytics_workspace_id = module.log_analytics.log_analytics_workspace_id
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Function
# ------------------------------------------------------------------------------------------------------

module "functions" {
  source                                      = "./modules/functions"
  location                                    = var.location
  resource_group_name                         = var.resource_group_name
  tags                                        = local.tags
  resource_token                              = local.resource_token
  managed_identity_principal_id               = module.managed_identity.user_assigned_identity_principal_id
  managed_identity_id                         = module.managed_identity.user_assigned_identity_id
  storage_account_name                        = module.storage_account.storage_account_name
  application_insights_connection_string      = module.application_insights.application_insights_connection_string
  application_insights_key                    = module.application_insights.application_insights_instrumentation_key
  storage_account_access_key                  = module.storage_account.storage_account_access_key
  storage_account_function_app_container_name = module.storage_account.function_app_container_name
  app_settings = {
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = module.application_insights.application_insights_connection_string
    "AzureWebJobsStorage" = module.storage_account.storage_account_connection_string
    "AzureWebJobsStorage__accountName"      = module.storage_account.storage_account_name
    "EVENT_HUB__fullyQualifiedNamespace"    = module.event_hub.event_hub_namespace_fqdn
    "EVENT_HUB_CENTRAL_NAME"                = module.event_hub.event_hub_central_name
    "EVENT_HUB_SIEM_NAME"                   = module.event_hub.event_hub_siem_name
    "EVENT_HUB__credential"                 = "managedidentity"
    "EVENT_HUB__clientId"                   = module.managed_identity.user_assigned_identity_client_id
    "FUNCTIONS_EXTENSION_VERSION"            = "~3"
  }
  sku_name                              = var.function_app.sku_name
  zone_balancing_enabled                = var.function_app.zone_balancing_enabled
  log_analytics_workspace_id            = module.log_analytics.log_analytics_workspace_id
  maximum_instance_count                = var.function_app.maximum_instance_count
  instance_memory_mb                    = var.function_app.instance_memory_mb
  storage_account_primary_blob_endpoint = module.storage_account.storage_account_primary_blob_endpoint
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Policy
# ------------------------------------------------------------------------------------------------------

# module "policy" {
#   source              = "./modules/policy"
#   location            = var.location
#   resource_group_name = var.resource_group_name
#   tags                = local.tags
#   resource_token      = local.resource_token
#   azure_policy_event_hub_authorization_rule_id = module.event_hub.azure_policy_central_logging_event_hub_authorization_rule
#   central_logging_event_hub_name = module.event_hub.event_hub_central_name
#   management_group_name = var.management_group_name
# }