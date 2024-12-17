resource "azurerm_policy_set_definition" "custom_diagnostic_logging_event_hub_monitoring_policy_set_definition" {
  name                = "custom-diagnostic-logging-event-hub-monitoring"
  policy_type         = "Custom"
  display_name        = "Custom Diagnostic Logging Event Hub Monitoring Policy Set Definition"
  management_group_id = data.azurerm_management_group.management_group.id
  metadata            = <<METADATA
    {
        "category": "Monitoring"
    }
METADATA

  parameters = <<PARAMETERS
    {
        "effect": {
        "type": "String",
        "metadata": {
          "displayName": "Effect",
          "description": "Enable or disable the execution of the policy"
        },
        "allowedValues": [
          "DeployIfNotExists",
          "AuditIfNotExists",
          "Disabled"
        ],
        "defaultValue": "DeployIfNotExists"
      },
      "diagnosticSettingName": {
        "type": "String",
        "metadata": {
          "displayName": "Diagnostic Setting Name",
          "description": "Diagnostic Setting Name"
        },
        "defaultValue": "setByPolicy-EventHub"
      },
      "resourceLocation": {
        "type": "String",
        "metadata": {
          "displayName": "Resource Location",
          "description": "Resource Location must be in the same location as the Event Hub Namespace.",
          "strongType": "location"
        }
      },
      "eventHubAuthorizationRuleId": {
        "type": "String",
        "metadata": {
          "displayName": "Event Hub Authorization Rule Id",
          "description": "Event Hub Authorization Rule Id - the authorization rule needs to be at Event Hub namespace level. e.g. /subscriptions/{subscription Id}/resourceGroups/{resource group}/providers/Microsoft.EventHub/namespaces/{Event Hub namespace}/authorizationrules/{authorization rule}",
          "strongType": "Microsoft.EventHub/Namespaces/AuthorizationRules",
          "assignPermissions": true
        }
      },
      "eventHubName": {
        "type": "String",
        "metadata": {
          "displayName": "Event Hub Name",
          "description": "Event Hub Name."
        },
        "defaultValue": "Monitoring"
      }
    }
PARAMETERS

  policy_definition_reference {
    policy_definition_id = azurerm_policy_definition.app_service_diagnostic_logging_event_hub_policy.id
    parameter_values     = <<VALUE
    {
        "effect": {"value": "[parameters('effect')]"},
        "diagnosticSettingName": {"value": "[parameters('diagnosticSettingName')]"},
        "resourceLocation": {"value": "[parameters('resourceLocation')]"},
        "eventHubAuthorizationRuleId": {"value": "[parameters('eventHubAuthorizationRuleId')]"},
        "eventHubName": {"value": "[parameters('eventHubName')]"}
    }
    VALUE
  }
}

