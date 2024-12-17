resource "azurerm_policy_definition" "app_service_diagnostic_logging_event_hub_policy" {
  name                = "app-service-diagnostic-logging-event-hub-policy"
  policy_type         = "Custom"
  mode                = "Indexed"
  display_name        = "Enable logging by category group for App Service (microsoft.web/sites) to Event Hub"
  management_group_id = data.azurerm_management_group.management_group.id
  metadata            = <<METADATA
    {
    "category": "Monitoring"
    }

METADATA


  policy_rule = <<POLICY_RULE
 {
    "if": {
        "allOf": [
          {
            "field": "type",
            "equals": "microsoft.web/sites"
          },
          {
            "field": "location",
            "equals": "[parameters('resourceLocation')]"
          }
        ]
      },
      "then": {
        "effect": "[parameters('effect')]",
        "details": {
          "type": "Microsoft.Insights/diagnosticSettings",
          "evaluationDelay": "AfterProvisioning",
          "existenceCondition": {
            "allOf": [
              {
                "count": {
                  "field": "Microsoft.Insights/diagnosticSettings/logs[*]",
                  "where": {
                    "allOf": [
                      {
                        "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
                        "equals": "[equals(parameters('categoryGroup'), 'audit')]"
                      },
                      {
                        "field": "microsoft.insights/diagnosticSettings/logs[*].categoryGroup",
                        "equals": "audit"
                      }
                    ]
                  }
                },
                "equals": 1
              },
              {
                "count": {
                  "field": "Microsoft.Insights/diagnosticSettings/logs[*]",
                  "where": {
                    "allOf": [
                      {
                        "field": "Microsoft.Insights/diagnosticSettings/logs[*].enabled",
                        "equals": "[equals(parameters('categoryGroup'), 'allLogs')]"
                      },
                      {
                        "field": "microsoft.insights/diagnosticSettings/logs[*].categoryGroup",
                        "equals": "allLogs"
                      }
                    ]
                  }
                },
                "equals": 1
              },
              {
                "field": "Microsoft.Insights/diagnosticSettings/eventHubAuthorizationRuleId",
                "equals": "[parameters('eventHubAuthorizationRuleId')]"
              },
              {
                "field": "Microsoft.Insights/diagnosticSettings/eventHubName",
                "equals": "[parameters('eventHubName')]"
              }
            ]
          },
          "roleDefinitionIds": [
            "/providers/Microsoft.Authorization/roleDefinitions/92aaf0da-9dab-42b6-94a3-d43ce8d16293",
            "/providers/Microsoft.Authorization/roleDefinitions/f526a384-b230-433a-b45c-95f59c4a2dec"
          ],
          "deployment": {
            "properties": {
              "mode": "incremental",
              "template": {
                "$schema": "http://schema.management.azure.com/schemas/2019-08-01/deploymentTemplate.json#",
                "contentVersion": "1.0.0.0",
                "parameters": {
                  "diagnosticSettingName": {
                    "type": "string"
                  },
                  "categoryGroup": {
                    "type": "String"
                  },
                  "eventHubName": {
                    "type": "string"
                  },
                  "eventHubAuthorizationRuleId": {
                    "type": "string"
                  },
                  "resourceLocation": {
                    "type": "string"
                  },
                  "resourceName": {
                    "type": "string"
                  }
                },
                "variables": {},
                "resources": [
                  {
                    "type": "microsoft.web/hostingenvironments/providers/diagnosticSettings",
                    "apiVersion": "2021-05-01-preview",
                    "name": "[concat(parameters('resourceName'), '/', 'Microsoft.Insights/', parameters('diagnosticSettingName'))]",
                    "location": "[parameters('resourceLocation')]",
                    "properties": {
                      "eventHubName": "[parameters('eventHubName')]",
                      "eventHubAuthorizationRuleId": "[parameters('eventHubAuthorizationRuleId')]",
                      "logs": [
                        {
                          "categoryGroup": "audit",
                          "enabled": "[equals(parameters('categoryGroup'), 'audit')]"
                        },
                        {
                          "categoryGroup": "allLogs",
                          "enabled": "[equals(parameters('categoryGroup'), 'allLogs')]"
                        }
                      ],
                      "metrics": []
                    }
                  }
                ],
                "outputs": {
                  "policy": {
                    "type": "string",
                    "value": "[concat('Diagnostic setting ', parameters('diagnosticSettingName'), ' for type App Service (microsoft.web/sites), resourceName ', parameters('resourceName'), ' to EventHub ', parameters('eventHubAuthorizationRuleId'), ':', parameters('eventHubName'), ' configured')]"
                  }
                }
              },
              "parameters": {
                "diagnosticSettingName": {
                  "value": "[parameters('diagnosticSettingName')]"
                },
                "categoryGroup": {
                  "value": "[parameters('categoryGroup')]"
                },
                "eventHubName": {
                  "value": "[parameters('eventHubName')]"
                },
                "eventHubAuthorizationRuleId": {
                  "value": "[parameters('eventHubAuthorizationRuleId')]"
                },
                "resourceLocation": {
                  "value": "[field('location')]"
                },
                "resourceName": {
                  "value": "[field('name')]"
                }
              }
            }
          }
        }
      }
  }
POLICY_RULE


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
      "categoryGroup": {
        "type": "String",
        "metadata": {
          "displayName": "Category Group",
          "description": "Diagnostic category group - none, audit, or allLogs."
        },
        "allowedValues": [
          "audit",
          "allLogs"
        ],
        "defaultValue": "audit"
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

}

