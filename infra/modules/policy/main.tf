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
  }
}
# ------------------------------------------------------------------------------------------------------
# Deploy Policies
# ------------------------------------------------------------------------------------------------------
data "azurerm_management_group" "management_group" {
  name = var.management_group_name
}



resource "azurerm_management_group_policy_assignment" "built_in_diagnostic_logging_event_hub_group_policy_assignment" {
  name                 = "built-in-diag-siem-log"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/85175a36-2f12-419a-96b4-18d5b0096531"
  management_group_id  = data.azurerm_management_group.management_group.id
  location             = var.location
  identity {
    type = "SystemAssigned"
  }
  parameters = jsonencode({
    resourceLocation = {
      value = var.location
    }
    eventHubAuthorizationRuleId = {
      value = var.azure_policy_event_hub_authorization_rule_id
    }
    eventHubName = {
      value = var.central_logging_event_hub_name
    }
    resourceTypeList = {
      value = var.resource_types
    }
  })
}

resource "azurerm_role_assignment" "built_in_diagnostic_logging_event_hub_group_policy_log_analytics_contributor_role_assignment" {
  scope                = data.azurerm_management_group.management_group.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_management_group_policy_assignment.built_in_diagnostic_logging_event_hub_group_policy_assignment.identity[0].principal_id
}

resource "azurerm_role_assignment" "built_in_diagnostic_logging_event_hub_group_policy_azure_event_hubs_data_owner_role_assignment" {
  scope                = data.azurerm_management_group.management_group.id
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = azurerm_management_group_policy_assignment.built_in_diagnostic_logging_event_hub_group_policy_assignment.identity[0].principal_id
}

resource "azurerm_management_group_policy_assignment" "custom_diagnostic_logging_event_hub_group_policy_assignment" {
  name                 = "custom-diag-siem-log"
  policy_definition_id = azurerm_policy_set_definition.custom_diagnostic_logging_event_hub_monitoring_policy_set_definition.id
  management_group_id  = data.azurerm_management_group.management_group.id
  location             = var.location
  identity {
    type = "SystemAssigned"
  }
  parameters = jsonencode({
    resourceLocation = {
      value = var.location
    }
    eventHubAuthorizationRuleId = {
      value = var.azure_policy_event_hub_authorization_rule_id
    }
    eventHubName = {
      value = var.central_logging_event_hub_name
    }
  })
}

resource "azurerm_role_assignment" "custom_diagnostic_logging_event_hub_group_policy_log_analytics_contributor_role_assignment" {
  scope                = data.azurerm_management_group.management_group.id
  role_definition_name = "Log Analytics Contributor"
  principal_id         = azurerm_management_group_policy_assignment.custom_diagnostic_logging_event_hub_group_policy_assignment.identity[0].principal_id
}

resource "azurerm_role_assignment" "custom_diagnostic_logging_event_hub_group_policy_azure_event_hubs_data_owner_role_assignment" {
  scope                = data.azurerm_management_group.management_group.id
  role_definition_name = "Azure Event Hubs Data Owner"
  principal_id         = azurerm_management_group_policy_assignment.custom_diagnostic_logging_event_hub_group_policy_assignment.identity[0].principal_id
}