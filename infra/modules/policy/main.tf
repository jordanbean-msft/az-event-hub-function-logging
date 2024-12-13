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

resource "azurerm_management_group_policy_assignment" "central_logging" {
  name                 = "central-logging"
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/85175a36-2f12-419a-96b4-18d5b0096531"
  management_group_id  = data.azurerm_management_group.management_group.id
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
