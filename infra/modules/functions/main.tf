terraform {
  required_providers {
    azurerm = {
      version = "~>4.14.0"
      source  = "hashicorp/azurerm"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf"
      version = "1.2.28"
    }
    azapi = {
      source  = "Azure/azapi"
      version = "1.15.0"
    }
  }
}

locals {
  app_settings_json = jsonencode([
    for key, value in var.app_settings : {
      name  = key
      value = value
    }
  ])
}

# ------------------------------------------------------------------------------------------------------
# Deploy Azure Function
# ------------------------------------------------------------------------------------------------------
resource "azurecaf_name" "service_plan_name" {
  name          = var.resource_token
  resource_type = "azurerm_app_service_plan"
  random_length = 0
  clean_input   = true
}

resource "azurerm_service_plan" "service_plan" {
  name                   = azurecaf_name.service_plan_name.result
  location               = var.location
  resource_group_name    = var.resource_group_name
  os_type                = "Linux"
  sku_name               = var.sku_name
  tags                   = var.tags
  zone_balancing_enabled = var.zone_balancing_enabled
}

resource "azurecaf_name" "function_name" {
  name          = var.resource_token
  resource_type = "azurerm_function_app"
  random_length = 0
  clean_input   = true
}

data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azapi_resource" "function_app" {
  type                      = "Microsoft.Web/sites@2023-12-01"
  schema_validation_enabled = false
  location                  = var.location
  name                      = azurecaf_name.function_name.result
  parent_id                 = data.azurerm_resource_group.resource_group.id
  tags = merge(var.tags, { "azd-service-name": "siem-logging"})
  body = jsonencode({
    kind = "functionapp,linux",
    identity = {
      type : "UserAssigned",
      userAssignedIdentities : {
        "${var.managed_identity_id}" : {}
      }
    }
    properties = {
      serverFarmId = azurerm_service_plan.service_plan.id,
      functionAppConfig = {
        deployment = {
          storage = {
            type  = "blobcontainer",
            value = "${var.storage_account_primary_blob_endpoint}${var.storage_account_function_app_container_name}",
            authentication = {
              type = "userassignedidentity"
              userAssignedIdentityResourceId = var.managed_identity_id
            }
          }
        },
        scaleAndConcurrency = {
          maximumInstanceCount = var.maximum_instance_count,
          instanceMemoryMB     = var.instance_memory_mb
        },
        runtime = {
          name    = "python",
          version = "3.11"
        }
      },
      siteConfig = {
        appSettings = jsondecode(local.app_settings_json)
      }
    }
  })
  depends_on = [azurerm_service_plan.service_plan]
}

resource "azurerm_monitor_diagnostic_setting" "function_logging" {
  name                       = "function-logging"
  target_resource_id         = azapi_resource.function_app.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FunctionAppLogs"
  }

  metric {
    category = "AllMetrics"
  }
}